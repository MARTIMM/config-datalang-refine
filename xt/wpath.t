use v6.c;
use Test;

subtest {

  say 'Resolve: ', '.'.IO.resolve.Str;
  say 'Abspath: ', '.'.IO.abspath;
  say 'Volume1: ', '.'.IO.volume;
  say 'Volume2: ', '.'.IO.resolve.volume;



  ok 1 == 1, 'always ok';
}, 'windows path tests';

done-testing;
