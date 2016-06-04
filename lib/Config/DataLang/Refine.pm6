use v6.c;
use File::HomeDir;

#-------------------------------------------------------------------------------
unit class Config::DataLang::Refine:ver<0.3.0>:auth<github:MARTIMM>;

has Str $!config-name;
has Hash $.config;

subset StrMode of Int where 10 <= $_ <= 11;
constant C-URI-OPTS is export             = 10;
constant C-UNIX-OPTS-T1 is export         = 11;
#constant C-UNIX-OPTS-T2         = 10 is export;

#-------------------------------------------------------------------------------
submethod BUILD (
  Str :$config-name is copy,
  Bool :$merge = False,
  Array :$locations is copy = [],
  Str :$data-module = 'Config::TOML'
) {

  # Import proper routine and select read routine
  my Sub $read-from-text;
  my Str $extension;
  given $data-module {
    when 'Config::TOML' {
      require ::($data-module) <&from-toml>;
      $read-from-text = &from-toml;
      $extension = '.toml';
    }

    when 'JSON::Fast' {
      require ::($data-module) <&from-json>;
      $read-from-text = &from-json;
      $extension = '.json';
    }

    default {
      die "Module $data-module not supported (yet)";
    }
  }

  # Read and deserialize text from file
  my Str $config-content;

  # Read file only once
  if not $!config.defined {

    # Check name
    if $config-name.defined {

      # Check if name holds complete path, relative or absolute
      if $config-name ~~ m/<[/]>+/ {
        my Str $base-name = $config-name.IO.basename;
        my Str $p = $config-name.IO.resolve.Str;
        $p ~~ s/<[/]>? $base-name $//;
        $locations.push($p);
        $config-name = $base-name;
      }
    }

    # If user didn't define a name, derive it from the program name
    else {
      $config-name = $*PROGRAM.basename;
      my Str $ext = $*PROGRAM.extension;
      $config-name ~~ s/\.$ext// if $ext.defined;
      $config-name ~= $extension;
    }

    if $merge {

      $config-content = '';
      $!config = {};
      for |(map {[~] .IO.resolve.Str, '/', $config-name}, @$locations),
          File::HomeDir.my-home ~ "/.$config-name",
          ".$config-name", $config-name -> $cfg-name {

        if $cfg-name.IO ~~ :r {
          $config-content = slurp($cfg-name) ~ "\n";

#say "Merge $cfg-name";

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
          File::HomeDir.my-home ~ "/.$config-name",
          |(map {[~] .IO.resolve.Str, '/', $config-name}, @$locations)
          -> $cfg-name {

#say "Search $cfg-name";

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
  }
}

#-------------------------------------------------------------------------------
method refine ( *@key-list, Bool :$filter = False --> Hash ) {

  my Hash $refined-list = {};
  my Hash $s = $!config;

  for @key-list -> $refine-key {

    last unless $s{$refine-key}:exists and $s{$refine-key}.defined;
    $s = $s{$refine-key};

    for $s.keys -> $k {
      next if $s{$k} ~~ Hash;
      $refined-list{$k} = $s{$k};

      # Looks like too much but it isn't. It must be able to remove
      # previously set entries.
      $refined-list{$k}:delete if $filter and $s{$k} ~~ Bool and !$s{$k};
    }
  }

  $refined-list;
}

#-------------------------------------------------------------------------------
method refine-str (
  *@key-list,
  Str :$glue = ',',
  Bool :$filter = False,
  StrMode :$str-mode = C-URI-OPTS;
  --> Array
) {

  my Str $entry;
  my Array $refined-list = [];
  my Hash $o = self.refine( @key-list, :$filter) // {};

  for $o.kv -> $k, $v {

    given $str-mode {
      when C-URI-OPTS {
        $entry = "$k=";
      }
      
      when C-UNIX-OPTS-T1 {
        if $k.chars == 1 {
          $entry = "-$k";
        }
        
        else {
          $entry = ( $v ~~ Bool and ?$v ) ?? "--$k" !! "--$k="; 
        }
      }
    }

    given $v {
      # should not happen
      when Hash {
        next;
      }

      when Array {
        $entry ~= $v.join($glue);
      }

      when Bool {
        $entry = $str-mode ~~ C-URI-OPTS ?? "$k=$v" !! "";
      }

      when /\s/ {
        $entry ~= "'$v'";
      }

      default {
        $entry ~= $v;
      }
    }

    $refined-list.push: $entry;
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

