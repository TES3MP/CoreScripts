Threads
===
Out of the box, there is no thread support in Lua. TES3MP uses [the `effil` library](https://github.com/effil/effil) to implement them, and provides a slightly more convenient API in the form of `threadHandler`.  
For most scripts, there is no reason to interact with it directly, however if you need to perform a task which takes more than half a second, and happens during the server active (roughly between the first player connects, and the server exits), you should consider moving it into a separate thread.  

>No example for now, `threadHandler` should probably have a few functions for interacting with the main thread