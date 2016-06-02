use v6.c;
use File::HomeDir;

#-------------------------------------------------------------------------------
unit class Config::DataLang::Refine:ver<0.0.2>:auth<github:MARTIMM>;

has Str $!config-name;
has Hash $.config;

#-------------------------------------------------------------------------------
submethod BUILD (
  Str :$config-name is copy,
  Bool :$merge = False,
  Str :$data-module = 'Config::TOML';
#  Array :$locations = [] is copy
) {

  my Sub $read-from-text;
  given $data-module {
    when 'Config::TOML' {
      require ::($data-module) <&from-toml>;
      $read-from-text = &from-toml;
    }

    when 'JSON::Fast' {
      require ::($data-module) <&from-json>;
      $read-from-text = &from-json;
    }

    default {
      die "Module $data-module not supported (yet)";
    }
  }

  my Str $config-content;

  # Read file only once
  if not $!config.defined {

    # If user didn't define a name, derive it from the program name
    unless $config-name.defined {
      $config-name = $*PROGRAM.basename;
      my Str $ext = $*PROGRAM.extension;
      $config-name ~~ s/\.$ext// if $ext.defined;
      $config-name ~= '.toml';
    }

    if $merge {

      $config-content = '';
      $!config = {};
      for File::HomeDir.my-home ~ "/.$config-name",
          ".$config-name", $config-name -> $cfg-name {

        if $cfg-name.IO ~~ :r {
          $config-content = slurp($cfg-name) ~ "\n";

          # Parse config file if exists
          $!config = self!merge-hash( $!config, $read-from-text($config-content));
        }
      }

      unless $!config.elems {
        die "Config files derived from $config-name not found or empty in current directory (plain or hidden) or in home directory";
      }
    }

    else {

      for $config-name, ".$config-name",
          File::HomeDir.my-home ~ "/.$config-name" -> $cfg-name {

        if $cfg-name.IO ~~ :r {
          $config-content = slurp($cfg-name);
          last;
        }
      }

      unless ?$config-content {
        die "Config file $config-name not found in current directory (plain or hidden) or in home directory";
      }

      # Parse config file if exists
      $!config = $read-from-text($config-content);
    }

    # Parse config file if exists
#say $!config.perl;
#say $!config<app><p1><workdir>;
  }
}

#-------------------------------------------------------------------------------
method refine ( *@key-list --> Hash ) {

  my Hash $refined-list = {};
  my Hash $s = $!config;

  for @key-list -> $refine-key {

    last unless $s{$refine-key}:exists and $s{$refine-key}.defined;
    $s = $s{$refine-key};

    for $s.keys -> $k {
      next if $s{$k} ~~ Hash;
      $refined-list{$k} = $s{$k};
    }
  }

  $refined-list;
}

#-------------------------------------------------------------------------------
method refine-filter ( *@key-list --> Hash ) {

  my Hash $refined-list = self.refine(@key-list) // {};
  for $refined-list.kv -> $k, $v {

    $refined-list{$k}:delete if $v ~~ Bool and !$v;
  }

  $refined-list;
}

#-------------------------------------------------------------------------------
method refine-filter-str ( *@key-list, Str :$glue = ',' --> Array ) {

  my Array $refined-list = [];
  my Hash $o = self.refine(@key-list) // {};
  for $o.kv -> $k, $v {

    given $v {
      # should not happen
      when Hash {
        next;
      }

      when Array {
        $refined-list.push: "$k=" ~ $v.join($glue);
      }

      when Bool {
        $refined-list.push: $k if $v;
      }

      when /\s/ {
        $refined-list.push: "$k='$v'";
      }

      default {
        $refined-list.push: "$k=$v";
      }
    }
  }

  $refined-list;
}

#-------------------------------------------------------------------------------
method !merge-hash ( Hash $h1, Hash $h2 --> Hash ) {

  my Hash $h3 = $h1;
  for $h2.kv -> $k, $v {

    if $v ~~ Hash {

      $h3{$k} = self!merge-hash( $h3{$k} // {}, $v);
    }

    else {

      $h3{$k} = $v;
    }
  }

  $h3 // {};
}

