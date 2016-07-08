----------------------------------------
-- @module tes3mp
--

-----------------------
-- Make function shared for other script (native, lua or pawn)
-- @tparam string func function
-- @tparam string func_name function name
-- @tparam string types types (i - unsigned int, q - signed int, f - double, s - string)
--
function tes3mp.MakePublic(func, func_name, types) end


-----------------------
-- Call shared function from native, lua or pawn
-- @function CallPublic
-- @tparam string function name
-- @param #... variable number of arguments (unsigned int, signed int, double, string)
-- @return result
--
function tes3mp.CallPublic(func, ...) end


-----------------------
-- TODO: description
-- @usage 
-- local id = tes3mp.CreateTimer("Callback", 5)
-- @function CreateTimer
-- @tparam string callback callback function
-- @tparam number time time in milliseconds before the callback call
-- @treturn number id id of timer
--
function tes3mp.CreateTimer(callback, time) end


-----------------------
-- TODO: description
-- @usage local id = tes3mp.CreateTimerEx("Callback", 5, "is", 42, "Forty-two")
-- StartTimer(id)
--
-- function Callback(QuestionOfLife, str)
--     print("The Ultimate Question of Life: ", str, tostring(42))
-- end
-- @function CreateTimerEx
-- @tparam string callback callback function
-- @tparam number time time in milliseconds before the callback call
-- @tparam string types types of callback args (i - unsigned int, q - signed int, f - double, s - string)
-- @param #... variable number of arguments
-- @treturn number id of timer asd
--
function tes3mp.CreateTimerEx(callback, time, types, ...) end


-----------------------
-- TODO: description
-- @tparam number id timer id
--
function tes3mp.StartTimer(id) end


-----------------------
-- TODO: description
-- @tparam number id timer id
--
function tes3mp.StopTimer(id) end


-----------------------
-- TODO: description
-- @tparam number id timer id
-- @tparam number msec time in milliseconds before the callback call
--
function tes3mp.ResetTimer(id, msec) end


-----------------------
-- TODO: description
-- @tparam number id timer id
-- @treturn boolean result
--
function tes3mp.IsEndTimer(id) end


