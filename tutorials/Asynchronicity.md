#### This chapter assumes you are familiar with the basics of [Lua Coroutines](https://www.lua.org/pil/9.html).

# Asynchronous functions

## Basics
Some of the CoreScript functions require you to run them inside a coroutine. To be able to pause execution of the current function, and then return to it, there must be some overlaying thread, to which we can `yield` during the pause. Otherwise there would be nothing that could resume execution in any case.

CoreScripts provides a global table `async' ([link to source](../scripts/async.lua)) to help with using asynchronous functions, which is described below.

If you are using functions such as `fileClient.SaveAsync`, `timers.WaitAsync`, `postgresClient.QueryAsync` or `threadHandler.SendAsync`, you should wrap them in a coroutine:
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

Some of the `Async` functions listed above can also run synchronously outside a coroutine, but others will throw an error, e. g. `timers.WaitAsync`:
```Lua
customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
  if eventStatus.validCustomHandlers then
    timers.WaitAsync(time.seconds(2)) -- throws an error
    print("2 seconds after server started!")
  end
end)
```

You can always use an `Async` function in callback style:
```Lua
async.Wrap(function()
  callback(fileClient.LoadAsync(filename))
end)
```

## Handling coroutine errors

Normally, if you simply run `coroutine.resume(co)`, any errors inside the coroutine will be ignored.  
Built-in `coroutine.wrap(co)` returns a function which resumes the coroutine and also handles any errors. However it is convenient to do the same for any coroutine.
* `async.Resume(co, ...)` resumes the coroutine with given arguments, handlers errors and returns the result
You should probably use this instead of `coroutine.resume` at all times, and use `pcall` inside the coroutine to deliberately ignore errors. This will make your code easier to debug and maintain.

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
However, in this case they will all run sequentially, task2 will wait for task1, task3 for task2...  
Sometimes this is exactly what you want. But if the order of execution doesn't matter, it is more efficient to run them all in parallel, by using a helper function:
* `async.WaitAll(funcs, timeout, callback)` where  
  * `funcs` is a table (it has to be an "array")  
  after `timeout` delay, it will resolve with whatever tasks have managed to complete. `timeout` can be `nil` if we want to wait forever  
  * `callback` will get called with a table of `results` (whatever the tasks return, or `nil`)  
* `async.WaitAllAsync(funcs, timeout)` same as `WaitAll`, but using coroutines. Instead of passing `results` into a `callback`, returns them

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

## Running asynchronous functions synchronously

* `async.RunBlocking(func, timeout)` where
  * `func` is the function which will be run synchronously.  
    You can nest as many coroutine scopes inside as you want, the main thread will wait for this function to finish.
  * `timeout` optional argument. Limits how long should the main thread wait for `func` to finish.  
    If the time is exceeded, an error is thrown.

An example:
```Lua
async.RunBlocking(function()
  timers.WaitAsync(time.seconds(1))
end)
```
This will freeze the server for a second.

There is an important limitation to `async.RunBlocking`. It can only be used with functions which do not depend on the tes3mp events to resolve. For example, none of the `guiHelper` functions can be ran this way: the server will endlessly wait, and will never actually receive the user's response.

## Refactoring your own callbacks into Async functions

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
Regardless of what `networkRequest` actually does, you could implement the following:
```Lua
function networkRequestAsync(url)
  local currentCoroutine = async.CurrentCoroutine()
  networkRequest(url, function(response)
    async.Resume(currentCoroutine, response)
  end)
  return coroutine.yield()
end
```
* `async.CurrentCoroutine()` simply returns the result of `coroutine.running()` or throws an error if it doesn't exist

Now use can use your new function in procedural style:
```Lua
async.Wrap(function()
  print(networkRequestAsync(url))
end)
```
