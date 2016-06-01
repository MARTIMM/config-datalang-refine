#Config::TOML refinements

#Synopsis

The following piece of code
```
use Config::TOML::Refine;

my Config::TOML::Refine $c .= new(:config-name<myConfig.toml>);

my Hash $hp1 = $c.refine(<options plugin1 test>);
my Hash $hp2 = $c.refine(<options plugin2 deploy>);
```
With the following config file in *myConfig.toml*

```
[options]
  key1 = 'val1'

[options.plugin1]
  key2 = 'val2'

[options.plugin1.test]
  key1 = false
  key2 = 'val3'

[options.plugin2.deploy]
  key3 = 'val3'
```
You get the following as if *$hp\** is set like
```
$hp1 = { key2 => 'val3' };
$hp2 = { key1 => 'val1', key3 => 'val3'};
```

#Description

The Config::TOML::Refine class adds facilities to use a TOML configuration file and gather the key value pairs by searching topdown a list of keys thereby refining the resulting set of keys. Boolean values are used to add a key without a value when True or to cancel a previously found key out when False.

The config file is searched for in the local directory. When not found it tries the hidden (on unix based systems) variant by adding a dot ('.') on front of the name. Then, if that one is not found, it tries the hidden variant in the users home directory. When a config file is found, it stops searching further and parses the file using Config::TOML.

There is an option :merge which is by default False. When turned on, it will merge all files into one configuration starting with the home directory file up to the visible file in the current directory. This will render the visible file overwriting the values in the hidden file and the keys from the home directory file.

The name of the file is given in :config-name. When absent, it will derive the name from the program substituting any extension with '.toml'.

The original config file can be retrieved of course.

#methods

##method new( Str :$config-name, Bool :$merge)

#Todo

#Changelog

* 0.0.1 Start of the project
