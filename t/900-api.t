use v6.c;
use Test;

use Config::DataLang::Refine;

spurt( 't/900-api.toml', Q:to/EOOPT/);
  # App control
  [app]
    workdir     = '/var/tmp'
    text        = 'abc def xyz'
  EOOPT

#-------------------------------------------------------------------------------
subtest {
  try {
    my Config::DataLang::Refine $rc .= new: :locations(['']);
  
    CATCH {
      when X::Config::DataLang::Refine {
        like .message, / :s Config file '900-api.toml' not found /, .message;
      }
    }
  }
}, 'api';

#-------------------------------------------------------------------------------
unlink 't/900-api.toml';
done-testing;
