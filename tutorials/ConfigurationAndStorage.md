# Configuration

While TES3MP's configuration is a lua file (`scripts/config.lua`), custom scripts are usually expected to provide a json configuration file, so that the end user can easily edit it manually.  
CoreScripts provide a simple function for this:
* `jsonConfig.Load(name, default, keyOrderArray)` returns a Lua table (equal to `default` when called for the first time)  
  `name` any unique (enforced only by convention) string,  
  `default` is a Lua table, containing default configuration values (will get written into the json file immediately)  
  `keyOrderArray`(optional) is the order in which table keys are put into JSON (Lua tables don't have fixed key order)

# Storage

You might also want to keep some dynamic data between server restarts. Regardless of which storage type a particular server is using (JSON files, Postgres database...), you can always use this function:
* `storage.Load(key, default)` returns a Lua table (equal to `default` when called for the first time)  
  `key` any unique (enforced only by convention) string,  
  `default` is a Lua table, containing default data values (gets saved immediately)

You don't have to worry about saving it, that will happen automatically at regular intervals and on server shutdown.
