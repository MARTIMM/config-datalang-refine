use v6.c;
use Test;
use Config::TOML::Refine;

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
subtest {

  my Config::TOML::Refine $c .= new;

  CATCH {
    default {
      like .message, / :s Config file .* not found/, .message;
    }
  }
}, 'Test build';

#-------------------------------------------------------------------------------
# Cleanup
#
#unlink 'genpath.cfg';
done-testing();
exit(0);
