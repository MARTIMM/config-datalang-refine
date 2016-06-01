use v6.c;
use File::HomeDir;
use Config::TOML;

#-------------------------------------------------------------------------------
unit class Config::TOML::Refine:ver<0.0.1>;

has Str $.config-name;
has Hash $.config;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$config-name is copy, Bool :$merge = False ) {

  my Str $orig-name = $config-name;
  my Str $config-content;

  # Read file only once
  if not $!config.defined {

    # If user didn't define a name, derive it from the program name
    unless $config-name.defined {
      $config-name = $*PROGRAM.basename;
      my Str $ext = $*PROGRAM.extension;
      $config-name ~~ s/\.$ext// if $ext.defined;
      $config-name ~= '.toml';
      $orig-name = $config-name;
    }
    
    if $merge {

      $config-content = '';
      $config-content = slurp($config-name) if $config-name.IO ~~ :r;

      $config-name = ".$config-name";
      $config-content ~= "\n" ~ slurp($config-name) if $config-name.IO ~~ :r;

      $config-name = File::HomeDir.my-home ~ "/$config-name";
      $config-content ~= "\n" ~ slurp($config-name) if $config-name.IO ~~ :r;
    }

    else {

      # Try xyz, .xyz or $home/.xyz
      if not $config-name.IO ~~ :r {
        $config-name = ".$config-name";
        if not $config-name.IO ~~ :r {
          $config-name = File::HomeDir.my-home ~ "/$config-name";
          if not $config-name.IO ~~ :r {
            die "Config file $orig-name not found in current directory (plain or hidden) or in home directory";
          }
        }
      }
    
      $config-content = slurp($config-name);
    }

    # Parse config file if exists
    $!config = from-toml($config-content);
  }
}

#-------------------------------------------------------------------------------
method refine ( ) {

}

#-------------------------------------------------------------------------------
method config ( ) {

}

