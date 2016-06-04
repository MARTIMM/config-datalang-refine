use v6.c;
use Test;
use Config::DataLang::Refine;

#-------------------------------------------------------------------------------
# First config
spurt( '.myCfg.cfg', Q:to/EOOPT/);
  # App control
  [app]
    workdir     = '/var/tmp'
    text        = 'abc def xyz'

  # App control for plugin p1
  [app.p1]
    workdir     = '/tmp'
    host        = 'example.com'

  # Plugin p2
  [p2]
    workdir     = '~/p2'
    times       = [10,11,12]
    tunnel      = true

  [app.p2]
    workdir     = '~/p2'
    tunnel      = true
    vision      = false

  EOOPT


# Second config
spurt( 'myCfg.cfg', Q:to/EOOPT/);
  # App control
  [app]
    port        = 2345

  # App control for plugin p1
  [app.p1]
    workdir     = '/tmp'

  [app.p2]
    workdir     = '~/p2'
    tunnel      = false
    vision      = true

  [p2]
    perl5lib    = [ 'lib', '.']

  [p2.env]
    PATH        = [ '/usr/bin', '/bin', '.']
    perl6lib    = [ 'lib', '.']
    perl5lib    = false

  EOOPT

#-------------------------------------------------------------------------------
subtest {

  try {
    my Config::DataLang::Refine $c .= new;

    CATCH {
      default {
        like .message, / :s Config file .* not found/, .message;
      }
    }
  }

  my Config::DataLang::Refine $c .= new(:config-name<myCfg.cfg>);
  ok $c.config<app><workdir>:!exists, 'no workdir';
  is $c.config<app><p1><workdir>, '/tmp', "workdir p1 $c.config()<app><p1><workdir>";
  ok $c.config<app><p1><host>:!exists, 'no host';
  is $c.config<app><p2><workdir>, '~/p2', "workdir p2 $c.config()<app><p2><workdir>";

  $c .= new( :config-name<myCfg.cfg>, :merge);
  is $c.config<app><workdir>, '/var/tmp', "workdir app $c.config()<app><workdir>";
  is $c.config<app><p1><workdir>, '/tmp', "workdir p1 $c.config()<app><p1><workdir>";
  is $c.config<app><p1><host>, 'example.com', "host p1 $c.config()<app><p1><host>";
  is $c.config<p2><workdir>, '~/p2', "workdir p2 $c.config()<p2><workdir>";
  is-deeply $c.config<p2><times>, [10,11,12], "times p2 $c.config()<p2><times>";
  nok $c.config<app><p2><tunnel>, 'tunnel p2 false';
  ok $c.config<app><p2><vision>, 'vision p2 true';

}, 'build tests';

#-------------------------------------------------------------------------------
subtest {

  my Config::DataLang::Refine $c .= new(:config-name<myCfg.cfg>);
  my Hash $o = $c.refine(<app>);
  ok $o<workdir>:!exists, "app has no workdir";
  is $o<port>, 2345, "port app $o<port>";

  $o = $c.refine(<app p1>);
  is $o<workdir>, '/tmp', "workdir p1 is $o<workdir>";
  is $o<port>, 2345, "port p1 $o<port>";


  $c .= new( :config-name<myCfg.cfg>, :merge);
  $o = $c.refine(<app>);
  is $o<workdir>, '/var/tmp', "workdir app $o<workdir>";
  is $o<port>, 2345, "port app $o<port>";

  $o = $c.refine(<app p1>);
  is $o<host>, 'example.com', "host p1 is $o<host>";
  is $o<port>, 2345, "port p1 $o<port>";

}, 'refine tests';

#-------------------------------------------------------------------------------
subtest {

  my Config::DataLang::Refine $c .= new(
    :config-name<myCfg.cfg>,
    :data-module<Config::TOML>
 );

  my Hash $o = $c.refine( <p2 env>, :filter);
say $o.perl;
  ok $o<perl5lib>:!exists, 'no perl5 lib';
  is-deeply $o<perl6lib>, [ 'lib', '.'], "perl6lib $o<perl6lib>";

}, 'refine filter hash tests';

#-------------------------------------------------------------------------------
subtest {

  my Config::DataLang::Refine $c .= new(:config-name<myCfg.cfg>);
  my Array $o = $c.refine-filter-str(<app>);
  ok 'port=2345' ~~ any(@$o), 'port in list';
  nok 'workdir=/tmp' ~~ any(@$o), 'workdir not in list';

  $o = $c.refine-filter-str(<app p2>);
  ok 'port=2345' ~~ any(@$o), 'port in list';
  ok 'workdir=~/p2' ~~ any(@$o), 'workdir in list';
  ok 'vision' ~~ any(@$o), 'vision in list';
  nok 'tunnel' ~~ any(@$o), 'tunnel not in list';


  $c .= new( :config-name<myCfg.cfg>, :merge);
  $o = $c.refine-filter-str(<app>);
  ok 'workdir=/var/tmp' ~~ any(@$o), 'app workdir in list';

  $o = $c.refine-filter-str(<app p2>);
  ok "text='abc def xyz'" ~~ any(@$o), 'p2 text in list';

  $o = $c.refine-filter-str(<p2>);
  ok 'workdir=~/p2' ~~ any(@$o), 'p2 workdir in list';
  ok 'times=10,11,12' ~~ any(@$o), 'p2 times in list';

}, 'refine filter string array tests';

#-------------------------------------------------------------------------------
# Cleanup
#
unlink 'myCfg.cfg';
unlink '.myCfg.cfg';
done-testing();
exit(0);
