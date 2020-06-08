#### This chapter assumes you are familiar with the basics of [Lua Coroutines](https://www.lua.org/pil/9.html).

# Asynchronous functions

## Basics
Some of the CoreScript functions require you to run them inside a coroutine. To be able to pause execution of the current function, and then return to it, there must be some overlaying thread, to which we can `yield` during the pause. Otherwise there would be nothing that could resume execution in any case.

So if you are using functions such as `timers.WaitAsync`, `postgresClient.QueryAsync` or `threadHandler.SendAsync`, you have to wrap them in a coroutine:
```Lua
customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
  if eventStatus.validCustomHandlers then
    timers.WaitAsync(time.seconds(2))
    print("2 seconds after server started!")
  end
end)
```
This code will throw an error! This is how you should do it instead:
```Lua
customEventHooks.registerHandler("OnServerPostInit", function()
  if eventStatus.validCustomHandlers then
    async.Wrap(function()
      timers.WaitAsync(time.seconds(2))
      print("2 seconds after server started!")
    end)
  end
end)
```
* `async.Wrap(func, ...)` is mostly identical to `coroutine.wrap(func)(...)`. You can use `coroutine.wrap` or `coroutine.create` functions instead, if you want more control over the specifics of implementation.

## Running multiple asynchronous functions

In this case, you might want to wait for all of them to complete before you continue. Obviously, you could simply do this:
```Lua
async.Wrap(function()
  task1Async()
  task2Async()
  ...
  task10Async()
  print("All tasks complete!")
end)
```
Or if you have them stored in a table, something like:
```Lua
async.Wrap(function()
  for _, task in pairs(tasks) do
    task()
  end
  print("All tasks complete!")
end)
```
However, in this case they will all run sequentially, task2 will wait for task 1, task 3 for task 2...  
Sometimes this is exactly what you want. But if the order of execution doesn't matter, it is more efficient to run them all in parallel, by using a helper function:
* `async.WaitAll(funcs, timeout, callback)` where  
  `funcs` is a table (it has to be an "array")  
  after `timeout` delay, it will resolve with whatever tasks have managed to complete. `timeout` can be `nil` if we want to wait forever  
  `callback` will get called with a table of `results` (whatever the tasks return, or `nil`)  
* `async.WaitAllAsync(funcs, timeout)` same as `WaitAll`, but using coroutines.  
  Instead of passing `results` into a `callback`, returns them

Here's the same example of a table with tasks we had before:
```Lua
async.WaitAll(tasks, time.seconds(5), function(results)
  print("All tasks complete!")
  tableHelp.print(results)
end)
```
A coroutine version:
```Lua
async.Wrap(function()
  local results = async.WaitAllAsync(tasks, time.seconds(5))
  print("All tasks complete!")
end)
```

## Refactoring your own callbacks into async functions
Let's assume you already have a function such as
```Lua
networkRequest(url, callback)
```
and you use it this way:
```Lua
networkRequest(url, function(response)
  print(response)
end)
```
Regardless of what networkRequest actually does, you could implement the following:
```Lua
function networkRequestAsync(url)
  local currentCoroutine = async.CurrentCoroutine()
  networkRequest(url, function(response)
    coroutine.resume(currentCoroutine, response)
  end)
  return coroutine.yield()
end
```
* `async.CurrentCoroutine()` simply returns the result of `coroutine.running()` or throws an error if it dosen't exist

Now use can use your new function in a procedural way:
```Lua
async.Wrap(function()
  print(networkRequestAsync(url))
end)
```
