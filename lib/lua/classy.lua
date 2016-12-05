-- class-based OO module for Lua

-- cache globals
local assert = assert
local V = assert( _VERSION )
local setmetatable = assert( setmetatable )
local select = assert( select )
local pairs = assert( pairs )
local ipairs = assert( ipairs )
local type = assert( type )
local error = assert( error )
local load = assert( load )
local s_rep = assert( string.rep )
local t_unpack = assert( V == "Lua 5.1" and unpack or table.unpack )


-- list of all metamethods that a user of this library is allowed to
-- add to a class
local allowed_metamethods = {
  __add = true, __sub = true, __mul = true, __div = true,
  __mod = true, __pow = true, __unm = true, __concat = true,
  __len = true, __eq = true, __lt = true, __le = true, __call = true,
  __tostring = true, __pairs = true, __ipairs = true, __gc = true,
  __newindex = true, __metatable = true, __idiv = true, __band = true,
  __bor = true, __bxor = true, __bnot = true, __shl = true,
  __shr = true,
}

-- this metatable is (re-)used often:
local mode_k_meta = { __mode = "k" }

-- store information for every registered class (still in use)
-- [ cls ] = {
--   -- the name of the class
--   name = "clsname",
--   -- an array of superclasses in an order suitable for method
--   -- lookup, the first n are direct superclasses (parents)
--   super = { n = 2, super1, super2, super1_1, super1_2 },
--   -- a set of subclasses (value is "inheritance difference")
--   sub = { [ subcls1 ] = 1, [ subcls2 ] = 2 }, -- mode="k"
--   -- direct member functions/variables for this class
--   members = {},
--   -- the metatable for objects of this class
--   o_meta = { __index = {} },
--   -- the metatable for the class itself
--   c_meta = { __index = ..., __call = ..., __newindex = ... },
-- }
local classinfo = setmetatable( {}, mode_k_meta )


-- object constructor for the class if no custom __init function is
-- defined
local function default_constructor( meta )
  return function()
    return setmetatable( {}, meta )
  end
end

-- object constructor for the class if a custom __init function is
-- available
local function init_constructor( meta, init )
  return function( _, ... )
    local o = setmetatable( {}, meta )
    init( o, ... )
    return o
  end
end


-- propagate a changed method to a sub class
local function propagate_update( cls, key )
  local info = classinfo[ cls ]
  if info.members[ key ] ~= nil then
    info.o_meta.__index[ key ] = info.members[ key ]
  else
    for i = 1, #info.super do
      local val = classinfo[ info.super[ i ] ].members[ key ]
      if val ~= nil then
        info.o_meta.__index[ key ] = val
        return
      end
    end
    info.o_meta.__index[ key ] = nil
  end
end


-- __newindex handler for class proxy tables, allowing to set certain
-- metamethods, initializers, and normal members. updates sub classes!
local function class_newindex( cls, key, val )
  local info = classinfo[ cls ]
  if allowed_metamethods[ key ] then
    assert( info.o_meta[ key ] == nil,
            "overwriting metamethods not allowed" )
    info.o_meta[ key ] = val
  elseif key == "__init" then
    info.members.__init = val
    info.o_meta.__index.__init = val
    if type( val ) == "function" then
      info.c_meta.__call = init_constructor( info.o_meta, val )
    else
      info.c_meta.__call = default_constructor( info.o_meta )
    end
  else
    assert( key ~= "__class", "key '__class' is reserved" )
    info.members[ key ] = val
    propagate_update( cls, key )
    for sub in pairs( info.sub ) do
      propagate_update( sub, key )
    end
  end
end


-- __pairs/__ipairs metamethods for iterating members of classes
local function class_pairs( cls )
  return pairs( classinfo[ cls ].o_meta.__index )
end

local function class_ipairs( cls )
  return ipairs( classinfo[ cls ].o_meta.__index )
end


-- put the inheritance tree into a flat array using a width-first
-- iteration (similar to a binary heap); also set the "inheritance
-- difference" in superclasses
local function linearize_ancestors( cls, super, ... )
  local n = select( '#', ... )
  for i = 1, n do
    local pcls = select( i, ... )
    assert( classinfo[ pcls ], "invalid class" )
    super[ i ] = pcls
  end
  super.n = n
  local diff, newn = 1, n
  for i,p in ipairs( super ) do
    local pinfo = classinfo[ p ]
    local psuper, psub = pinfo.super, pinfo.sub
    if not psub[ cls ] then psub[ cls ] = diff end
    for i = 1, psuper.n do
      super[ #super+1 ] = psuper[ i ]
    end
    newn = newn + psuper.n
    if i == n then
      n, diff = newn, diff+1
    end
  end
end


-- create the necessary metadata for the class, setup the inheritance
-- hierarchy, set a suitable metatable, and return the class
local function create_class( _, name, ... )
  assert( type( name ) == "string", "class name must be a string" )
  local cls, index = {}, {}
  local o_meta = {
    __index = index,
    __name = name,
  }
  local info = {
    name = name,
    super = { n = 0 },
    sub = setmetatable( {}, mode_k_meta ),
    members = {},
    o_meta = o_meta,
    c_meta = {
      __index = index,
      __newindex = class_newindex,
      __call = default_constructor( o_meta ),
      __pairs = class_pairs,
      __ipairs = class_ipairs,
      __name = "class",
      __metatable = false,
    },
  }
  linearize_ancestors( cls, info.super, ... )
  for i = #info.super, 1, -1 do
    for k,v in pairs( classinfo[ info.super[ i ] ].members ) do
      if k ~= "__init" then index[ k ] = v end
    end
  end
  index.__class = cls
  classinfo[ cls ] = info
  return setmetatable( cls, info.c_meta )
end


-- the exported class module
local M = {}
setmetatable( M, { __call = create_class } )


-- returns the class of an object
function M.of( o )
  return type( o ) == "table" and o.__class or nil
end


-- returns the class name of an object or class
function M.name( oc )
  if oc == nil then return nil end
  oc = type( oc ) == "table" and oc.__class or oc
  local info = classinfo[ oc ]
  return info and info.name
end


-- checks if an object or class is in an inheritance
-- relationship with a given class
function M.is_a( oc, cls )
  if oc == nil then return nil end
  local info = assert( classinfo[ cls ], "invalid class" )
  oc = type( oc ) == "table" and oc.__class or oc
  if oc == cls then return 0 end
  return info.sub[ oc ]
end


-- change the type of an object to the new class
function M.cast( o, newcls )
  local info = classinfo[ newcls ]
  if not info then
    error( "invalid class" )
  end
  setmetatable( o, info.o_meta )
  return o
end


local function make_delegate( cls, field, method )
  cls[ method ] = function( self, ... )
    local obj = self[ field ]
    return obj[ method ]( obj, ... )
  end
end

-- create delegation methods
function M.delegate( cls, fieldname, ... )
  if type( (...) ) == "table" then
    for k,v in pairs( (...) ) do
      if cls[ k ] == nil and k ~= "__init" and
         type( v ) == "function" then
        make_delegate( cls, fieldname, k )
      end
    end
  else
    for i = 1, select( '#', ... ) do
      local k = select( i, ... )
      if cls[ k ] == nil and k ~= "__init" then
        make_delegate( cls, fieldname, k )
      end
    end
  end
  return cls
end


-- multimethod stuff
do
  -- store multimethods and map them to the meta-data
  local mminfo = setmetatable( {}, mode_k_meta )

  local erroffset = 0
  if V == "Lua 5.1" then erroffset = 1 end

  local function no_match2()
    error( "no matching multimethod overload", 2+erroffset )
  end

  local function no_match3()
    error( "no matching multimethod overload", 3+erroffset )
  end

  local function amb_call()
    error( "ambiguous multimethod call", 3+erroffset )
  end

  local empty = {}   -- just an empty table used as dummy
  local FIRST_OL = 4 -- index of first overload specification


  -- create a multimethod using the parameter indices given
  -- as arguments for dynamic dispatch
  function M.multimethod( ... )
    local t, n = { ... }, select( '#', ... )
    assert( n >= 1, "no polymorphic parameter for multimethod" )
    local max = 0
    for i = 1, n do
      local x = t[ i ]
      max = assert( x > max and x % 1 == 0 and x,
                    "invalid parameter overload specification" )
    end
    local mm_impl = { no_match2, t, max }
    local function mm( ... )
      return mm_impl[ 1 ]( mm_impl, ... )
    end
    mminfo[ mm ] = mm_impl
    return mm
  end


  local function make_weak()
    return setmetatable( {}, mode_k_meta )
  end


  local function calculate_cost( ol, ... )
    local c = 0
    for i = 1, select( '#', ... ) do
      local a, pt = ol[ i ], select( i, ... )
      if type( a ) == "table" then -- class table
        local info = classinfo[ a ]
        local diff = (pt == a) and 0 or info and info.sub[ pt ]
        if not diff then return nil end
        c = c + diff
      else -- type name
        if pt ~= a then return nil end
      end
    end
    return c
  end


  local function select_impl( cost, f, amb, ol, ... )
    local c = calculate_cost( ol, ... )
    if c then
      if cost then
        if c < cost then
          cost, f, amb = c, ol.func, false
        elseif c == cost then
          amb = true
        end
      else
        cost, f, amb = c, ol.func, false
      end
    end
    return cost, f, amb
  end


  local function collect_type_checkers( mm, a )
    local funcs = {}, {}
    for i = FIRST_OL, #mm do
      local ol = mm[ i ]
      for k,v in pairs( ol ) do
        if type( k ) == "function" and
           (a == nil or v[ a ]) and
           not funcs[ k ] then
          local j = #funcs+1
          funcs[ j ] = k
          funcs[ k ] = j
        end
      end
    end
    return funcs
  end


  local function c_varlist( t, m, prefix )
    local n = #t
    if m >= 1 then
      t[ n+1 ] = prefix
      t[ n+2 ] = 1
    end
    for i = 2, m do
      local j = i*3+n
      t[ j-3 ] = ","
      t[ j-2 ] = prefix
      t[ j-1 ] = i
    end
  end

  local function c_typecheck( t, mm, funcs, j )
    local n, ai = #t, mm[ 2 ][ j ]
    t[ n+1 ] = "  t=type(_"
    t[ n+2 ] = ai
    t[ n+3 ] = ")\n  local t"
    t[ n+4 ] = j
    t[ n+5 ] = "=(t=='table' and _"
    t[ n+6 ] = ai
    t[ n+7 ] = ".__class) or "
    local ltcs = collect_type_checkers( mm, j )
    local m = #ltcs
    for i = 1, m do
      local k = i*5+n+3
      t[ k ] = "tc"
      t[ k+1 ] = funcs[ ltcs[ i ] ]
      t[ k+2 ] = "(_"
      t[ k+3 ] = ai
      t[ k+4 ] = ") or "
    end
    t[ m*5+n+8 ] = "t\n"
  end

  local function c_cache( t, mm )
    local c = #mm[ 2 ]
    local n = #t
    t[ n+1 ] = s_rep( "(", c-1 )
    t[ n+2 ] = "cache"
    for i = 1, c-1 do
      local j = i*3+n
      t[ j ] = "[t"
      t[ j+1 ] = i
      t[ j+2 ] = "] or empty)"
    end
    local j = c*3+n
    t[ j ] = "[t"
    t[ j+1 ] = c
    t[ j+2 ] = "]\n"
  end

  local function c_costcheck( t, i, j )
    local n = #t
    t[ n+1 ] = "    cost,f,is_amb=sel_impl(cost,f,is_amb,mm["
    t[ n+2 ] = j+FIRST_OL-1
    t[ n+3 ] = "],"
    c_varlist( t, i, "t" )
    t[ #t+1 ] = ")\n"
  end

  local function c_updatecache( t, i )
    local n = #t
    t[ n+1 ] = "    if not t[t"
    t[ n+2 ] = i
    t[ n+3 ] = "] then t[t"
    t[ n+4 ] = i
    t[ n+5 ] = "]=mk_weak() end\n    t=t[t"
    t[ n+6 ] = i
    t[ n+7 ] = "]\n"
  end


  local function recompile_and_call( mm, ... )
    local n = #mm[ 2 ] -- number of polymorphic parameters
    local tcs = collect_type_checkers( mm )
    local code = {
      "local type,cache,empty,mk_weak,sel_impl,no_match,amb_call"
    }
    if #tcs >= 1 then
      code[ #code+1 ] = ","
    end
    c_varlist( code, #tcs, "tc" )
    code[ #code+1 ] = "=...\nreturn function(mm,"
    c_varlist( code, mm[ 3 ], "_" )
    code[ #code+1 ] = ",...)\n  local t\n"
    for i = 1, n do
      c_typecheck( code, mm, tcs, i )
    end
    code[ #code+1 ] = "  local f="
    c_cache( code, mm )
    code[ #code+1 ] = [=[
  if f==nil then
    local is_amb,cost
]=]
    for i = 1, #mm-FIRST_OL+1 do
      c_costcheck( code, n, i )
    end
    code[ #code+1 ] = [=[
    if f==nil then
      no_match()
    elseif is_amb then
      amb_call()
    end
    t=cache
]=]
    for i = 1, n-1 do
      c_updatecache( code, i )
    end
    code[ #code+1 ] = "    t[t"
    code[ #code+1 ] = n
    code[ #code+1 ] = "]=f\n  end\n  return f("
    c_varlist( code, mm[ 3 ], "_" )
    code[ #code+1 ] = ",...)\nend\n"
    local i = 0
    local function ld()
      i = i + 1
      return code[ i ]
    end
    --print( table.concat( code ) ) -- XXX
    local f = assert( load( ld, "=[multimethod]" ) )(
      type, make_weak(), empty, make_weak, select_impl, no_match3,
      amb_call, t_unpack( tcs )
    )
    mm[ 1 ] = f
    return f( mm, ... )
  end


  -- register a new overload for this multimethod
  function M.overload( f, ... )
    local mm = assert( type( f ) == "function" and mminfo[ f ],
                       "argument is not a multimethod" )
    local i, n = 1, select( '#', ... )
    local ol = {}
    local func = assert( n >= 1 and select( n, ... ),
                         "missing function in overload specification" )
    while i < n do
      local a = select( i, ... )
      local t = type( a )
      if t == "string" then
        ol[ #ol+1 ] = a
      elseif t == "table" then
        assert( classinfo[ a ], "invalid class" )
        ol[ #ol+1 ] = a
      else
        assert( t == "function", "invalid overload specification" )
        i = i + 1
        assert( i < n, "missing function in overload specification" )
        ol[ a ] = ol[ a ] or {}
        ol[ #ol+1 ] = select( i, ... )
        ol[ a ][ #ol ] = true
      end
      i = i + 1
    end
    assert( #mm[ 2 ] == #ol, "wrong number of overloaded parameters" )
    ol.func = func
    mm[ #mm+1 ] = ol
    mm[ 1 ] = recompile_and_call
  end

end


-- return module table
return M

