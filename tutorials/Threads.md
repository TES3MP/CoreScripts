# Threads

Out of the box, there is no thread support in Lua. TES3MP uses [the `effil` library](https://github.com/effil/effil) to implement them, and provides a slightly higher level API in the form of `threadHandler` ([source code](../scripts/threadHandler.lua)).  
For most scripts, there is no reason to interact with it directly. However if you need to perform a task which takes more than half a second, and happens while the server is active (roughly between the first player connects, and the server exits), you should consider moving it into a separate thread.

## Interacting with threads

* `threadHandler.CreateThread(body, ...)` creates a new thread and returns its `id`
  Will run the function `body` with arguments `input`, `output` and `...`, where `input` and `output` are instances of `effil.channel`.
* `threadHandler.Send(id, message, callback)` sends `message` to thread with `id` and calls `callback` when it responds
* `threadHandler.SendAsync(id, message)` asynchronous version of Send

Keep in mind that `effil` must be able to serialize any values you pass to threads: arguments of `CreateThread` and `message` for `Send` functions. [Go here for more detail](https://github.com/effil/effil#important-notes).

## Implementing new threads
* `threadHandler.ReceiveMessages(input, output, callback)` you can call this function in the `body` function, passing `input` and `output` that it receives.  
  `callback` will be receiving `message` values from `Send` functions, and its result will be returned as response. Any thrown `error`s will not be considered a response, and will instead be logged.

The only thing left is to implement the `body` function and a `callback`. It is convenient to put most of the thread's code in a separate file and `require` it inside `body`, keeping the function itself as simple as possible:

```Lua
local thread = threadHandler.CreateThread(function(input, output)
  local Run = require('custom.MyScript.thread')
  Run(input, output)
end)
```
where the `scripts/custom/MyScript/thread.lua` file can look something like:
```Lua
local threadHandler = require('threadHandler')
local function Run(input, output)
  threadHandler.ReceiveMessages(input, output, function(message)
    return "echo of " .. message
  end)
end

return Run
``` 
Now you can send messages to it with
```Lua
async.Wrap(function()
  print(threadHandler.SendAsync(thread, "test"))
end)
```

This thread will simply echo any messages back. Obviously, in a real case it would be doing something more practical, such as performing network requests, or saving data to the drive.
