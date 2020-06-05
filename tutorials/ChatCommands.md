Commands
===

Using the API
===
To add a command, simply run `customCommandHooks.registerCommand(cmd, callback)`. Here `cmd` is the word after `/` which you want to trigger your command (e.g. "help" for `/help`) and callback is a function which will be ran when someone sends a message starting with it.

Callback will receive as its arguments a player's `pid` and a table of all command parts (their message is split into parts by spaces, after removing the leading '/', same as in the old `commandHandler.lua`).

You can limit which players can run the command with the following functions:
* `customCommandHooks.setRankRequirement(cmd, rank)` where `rank` is the same as in `Players[pid].data.settings.staffRank`
* `customCommandHooks.removeRankRequirement(cmd)`
* `customCommandHooks.setNameRequirement(cmd, names)` where `names` is a table of player `accountName`s
* `customCommandHooks.addNameRequirement(cmd, name)` where `name` is a player's `accountName`
* `customCommandHooks.removeNameRequirement(cmd)`

You can also perform more advanced checks inside the callback by calling `Players[pid]:IsAdmin()` and other similar functions.

Examples
---

