Timers
===

Timer functions are provided as a global `timers` table. All of them accept delay in milliseconds, but you can use [`time` functions](#time-unit-conversions) to convert diffirent units.

Timeout and Interval
---
* `timers.Timeout(func, delay)` returns `id`  
  Calls the function `func` with `id` as an argument (the same as the returned `id`) after `delay` milliseconds
* `timers.Interval(func, delay)` returns `id`  
  Same as Timeout, but continues calling `func` every `delay` milliseconds.
* `timers.Stop(id)`  
  Completely stops a Timeout or an Interval with the provided `id`.

If you want to pass any additional information to the callback `func`, either make use of closures, or keep track of it using timer `id`.

WaitAsync
---
You can also simply wait for a set amount of time, while not locking up the rest of the server:  
* `timers.WaitAsync(delay)`  
This function **must** be called from inside a [coroutine](Coroutines.md), and will throw an error otherwise. In the main thread this kind of operation is impossible, and you should use Timeout.

Examples
---
Display a notification two seconds after player joins the server:
```Lua
customEventHooks.registerHandler('OnPlayerAuthentified', function(eventStatus, pid)
  timers.Timeout(function(id)
    tes3mp.SendMessage(pid, color.Cornsilk .. 'Greetings!\n')
  end, time.seconds(2))
end)
```

Display the amount of online players every five minutes:
```Lua
customEventHooks.registerHandler('OnServerPostInit', function(eventStatus)
  timers.Interval(function(id)
    local count = 0
    for pid in pairs(Players) do
      count = count + 1
    end
    local message = string.format('%s%d players online!\n', color.Yellow, count)
    for pid in pairs(Players) do
      tes3mp.SendMessage(pid, message)
    end
  end, time.minutes(5))
end)
```

What if you want to wait for many different durations in a row?
Exit the server with multiple warnings:
```Lua
customCommandHooks.registerCommand("exit", function(pid, delayMinutes)
  local function printRemainingDelay(delay)
    local minutes = math.floor(time.toMinutes(delay))
    local seconds = time.toSeconds(delay % time.minute(1))
    local message = string.format('%sServer shutting down in %d minutes %d seconds!\n', color.DarkRed, minutes, seconds)
    for pid in pairs(Players) do
      tes3mp.SendMessage(pid, message)
    end
  end
  -- we will be using WaitAsync, so wrap everything in a coroutine
  threadHandler.Async(function()
    local delay = time.minutes(delayMinutes)

    printRemainingDelay(delay)
    timers.WaitAsync(delay * 0.5)
    delay = delay - delay * 0.5

    printRemainingDelay(delay)
    timers.WaitAsync(delay * 0.3)
    delay = delay - delay * 0.3

    printRemainingDelay(delay)
    timers.WaitAsync(delay * 0.15)
    delay = delay - delay * 0.15

    if delay > time.minutes(5) then
      printRemainingDelay(delay)
      timers.WaitAsync(time.minutes(5))
      delay = delay - time.minutes(5)
    end

    if delay > time.seconds(5) then
      printRemainingDelay(delay)
      timers.WaitAsync(time.seconds(5))
      delay = delay - time.seconds(5)
    end

    timers.WaitAsync(delay)
    printRemaingingDelay(0)
    tes3mp.StopServer(0)
  end)
end)
-- only allow admins to stop the server
customCommandHooks.setRankRequirement("exit", 2)
```

Time unit conversion
---
* `time.seconds(sec)`
* `time.minutes(min)`
* `time.hours(hours)`
* `time.days(day)`
* `time.toSeconds(msec)`
* `time.toMinutes(msec)`
* `time.toHours(msec)`
* `time.toDays(msec)`
