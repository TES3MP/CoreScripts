Introduction
===
Lua
---
TES3MP scripts are written in Lua (specifically LuaJIT 5.1).
If you are completely new to programming, I recommend you read through the entirety of [Programming in Lua](https://www.lua.org/pil/contents.html).
If you are an experienced programmer, but are not an expert in Lua, there a few peculiar parts of the language you should check out:
* [Basic types](https://www.lua.org/pil/2.html) for example, there are no traditional arrays in Lua
* [Coroutines](https://www.lua.org/pil/9.html) a very powerful way to implement generators and asynchronicity
* [OOP](https://www.lua.org/pil/16.html) object-oriented programming approach similar to JavaScript prototypes
* [Closures](https://www.lua.org/pil/6.1.html) a very useful detail of variable scopes in Lua

API
---
Integration with the TES3MP server itself happens mostly through calls to a lua binding available as a global table `tes3mp`. You can find the [current documentation here](http://docs.tes3mp.com/en/latest/). However for most of the use cases there are higher level functions available in CoreScripts, and you should strive to use those as much as possible.
Additionally, the server calls Lua code directly through [Events](EventHooks.md) and [Timers](Timers.md).
The main server applications only receives and sends packets. Most of the logic is performed by CoreScripts.

Module format
---
Currently, the process of installing a custom script by the end user consists of adding [require statements](https://www.lua.org/pil/8.1.html) to the `customScripts.lua` file.
Thus you want to minimize the amount of files that must be required. For smaller scripts that can be achieved simply by putting all of your code in a single file, but for larger ones you might want to have a file that requires the others, assembling your script into a single module.
It is generally a good practice to form each of your scripts as a single table, and then `return` it. This way you don't pollute global variable space and make it easier for other scripts to reuse your code.

Other resources
---
As a quick introduction, [take a look at examples](Examples).