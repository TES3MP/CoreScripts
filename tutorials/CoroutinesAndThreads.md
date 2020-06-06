This chapter  assumes you are familiar with basics of [Lua Coroutines](https://www.lua.org/pil/9.html).
---

Asynchronous functions
===
Some of the CoreScript functions require you to run them inside a coroutine. This is the case, because to be able to pause execution of the current function, and then return it to it, there must be some overlaying thread, to which we can `yield` during the pause. Otherwise there would be nothing that could resume execution in any case.

So if you are using functions such as `timers.WaitAsync`, `postgresClient.QueryAwait` or `threadHandler.SendAwait`, you have to wrap them in a coroutine:
```Lua
customEventHooks.registerHandler("OnServerPostInit", function()
  timers.WaitAsync(time.seconds(2))
  print("2 seconds after server started!")
end)
```
This code will throw an error! This is how you should do it instead:
```Lua
customEventHooks.registerHandler("OnServerPostInit", function()
  threadHandler.Async(function()
    timers.WaitAsync(time.seconds(2))
    print("2 seconds after server started!")
  end)
end)
```
`threadHandler.Async(func, ...)` is mostly identical to `coroutine.wrap(func)(...)`, and you can use `coroutine.wrap` or `coroutine.create` functions instead, if you want more control over the specifics of implementation.

>Add threadHandler.AwaitAll here

Threads
===
Out of the box, there is no thread support in Lua. TES3MP uses [the `effil` library](https://github.com/effil/effil) to implement them, and provides a slightly more convenient API in the form of `threadHandler`.  
For most scripts, there is no reason to interact with it directly, however if you need to perform a task which takes more than half a second, and happens during the server active (roughly between the first player connects, and the server exits), you should consider moving it into a separate thread.  

>No example for now, `threadHandler` should probably have a few functions for interacting with the main thread