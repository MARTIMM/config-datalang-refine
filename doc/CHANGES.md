
The **Config::DataLang::Refine** class adds facilities to use a configuration file and gather the key value pairs by searching top down a list of keys thereby refining the resulting set of keys. Boolean values are used to add a key without a value when True or to cancel a previously found key out when False. For details see the pod file or [pdf](https://github.com/MARTIMM/config-datalang-refine/blob/master/doc/Refine.pdf).

* 0.3.5
  * housekeeping shores
* 0.3.4
  * Panda problems
* 0.3.3
  * Added modes used to create strings with refine-str.
* 0.3.2
  * Removed **refine-filter()** and added named argument **:filter** to **refine()**.
  * Renamed **refine-filter-str()** to **refine-str()** and added named argument **:filter**.
* 0.3.1
  * Bugfix in use of **:locations** array and relative/absolute path usage in **:config-name**.
* 0.3.0
  * Use **:data-module** to select other modules to load other types of config files. Possible configuration data languages are Config::TOML and JSON::Fast.
* 0.2.0
  * methods **refine()**, **refine-filter()**. **refine-filter-str()** added
* 0.1.0
  * setup using config language **Config::TOML**
  * method **new()** to read config files and **:merge**
  * method refine to get key value pairs
* 0.0.1 Start of the project
