#Config::TOML refinements

#Synopsis
```
use Config::TOML::Refine;

my Config::TOML::Refine $c .= new(:cfg-name<myConfig.toml>);

my Hash $hp1 = $c.get-config(<options plugin1 test>);
my Hash $hp2 = $c.get-config(<options plugin2 deploy>);
```
With the following config file in *myConfig.toml*

```
[options]
  key1 = val1

[options.plugin1]
  key2 = val2

[options.plugin1.test]
  key1 = false
  key2 = val3

[options.plugin2.deploy]
  key3 = val3
```
You get the following as if *$hp\** is set like
```
$hp1 = { key2 => 'val3' };
$hp2 = { key1 => 'val1', key3 => 'val3'};
```

#Todo

#Changelog

* 0.0.1 Start of the project
