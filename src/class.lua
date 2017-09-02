--------------------------------------------------------------
--        file:  class.lua
--       brief:  Object Orientation for Lua
--
--      author:  VyronLee, lwz_jz@hotmail.com
--
--    Modified:  2017-03-13 18:19
--   Copyright:  Copyright (c) 2017, VyronLee
--============================================================

local class = {
    _AUTHOR      = "VyronLee (lwz_jz@hotmail.com)",
    _LICENSE     = "MIT License",
    _VERSION     = "v1.0.2",
    _VERBOSE     = 0,
}

local assert = assert
local setmetatable = setmetatable
local rawget = rawget
local gmatch = string.gmatch
local gsub   = string.gsub
local fopen  = io.open
local fclose = io.close
local setfenv = setfenv

local __hash_code = 0x0
local __hash_code_generator = function()
    __hash_code = __hash_code + 1
    return __hash_code
end

local __instance_equal_comparator = function(l, r)
    return l.__hashcode == r.__hashcode
end

local __default_alloc = function(a_class)
    local instance = {
        __hashcode = __hash_code_generator(),
        __class    = a_class,
    }

    local meta = {
        __index = a_class,
        __eq = __instance_equal_comparator,
        __tostring = function()
            return string.format("%s: 0x%X", instance.__name, instance.__hashcode)
        end,
    }
    if class._VERBOSE >= 1 then
        meta.__gc = function(t)
            print("An instance has collected, " .. tostring(t))
        end
    end
    setmetatable(instance, meta)

    if class._VERBOSE >= 1 then
        print("An instance has allocated, " .. tostring(instance))
    end

    return instance
end

local __default_dealloc = function(an_instance)
    -- nothing to do
end

local __depth_first_initialize, __bread_first_uninitialize

__depth_first_initialize = function(a_class, an_instance, ...)
    if a_class.__super then
        __depth_first_initialize(a_class.__super, an_instance, ...)
    end
    local initializer = rawget(a_class, "initialize")
    if initializer then
        initializer(an_instance, ...)
    end
end

__bread_first_uninitialize = function(a_class, an_instance)
    local uninitializer = rawget(a_class, "uninitialize")
    if uninitializer then
        uninitializer(an_instance)
    end
    if a_class.__super then
        __bread_first_uninitialize(a_class.__super, an_instance)
    end
end

local classbase = {
    new = function(a_class, ...)
        assert(type(a_class) == "table", "You must use Class:new() instead of Class.new()")

        local instance = a_class:allocate()
        __depth_first_initialize(a_class, instance, ...)
        return instance
    end,

    destroy = function(an_instance)
        assert(type(an_instance) == "table", "You must use Class:destroy() instead of Class.destroy()")

        __bread_first_uninitialize(an_instance.__class, an_instance)
        an_instance:deallocate()
    end,

    allocate = function(a_class, ...)
        if a_class.__alloc then
            return a_class:__alloc()
        end
        return __default_alloc(a_class)
    end,

    deallocate = function(an_instance, ...)
        if an_instance.__dealloc then
            return an_instance:__dealloc()
        end
        __default_dealloc(an_instance)
    end,

    default_alloc   = __default_alloc,
    default_dealloc = __default_dealloc,
}

local __get_super_base

__get_super_base = function(tocheck)
    if tocheck.__hashcode then
        return __get_super_base(tocheck.__class)
    end
    return tocheck.__super and __get_super_base(tocheck.__super) or tocheck
end

local __is_class = function(target)
    return __get_super_base(target) == classbase
end

local __is_instance = function(target)
    return not not target.__hashcode
end

local __typeof = function(target)
    assert(__is_class(target), "__typeof() - `target` must be a class or an instance!" )

    if __is_instance(target) then
        return target.__class
    end
    return target
end

local __is_subclass_of = function(subclass, super)
    assert(__is_class(subclass), "__is_subclass_of() - `subclass` is not a class!")
    assert(__is_class(super), "__is_subclass_of() - `super` is not a class!")
    assert(not __is_instance(subclass), "__is_subclass_of() - `subclass` cannot be an instance!")
    assert(not __is_instance(subclass), "__is_subclass_of() - `super` cannot be an instance!")

    local cls = subclass
    repeat
        if rawget(cls, "__name") == rawget(super, "__name") then
            return true
        end
        cls = cls.__super
    until not cls

    return false
end

local __is_instance_of = function(an_instance, a_class)
    assert(__is_class(an_instance), "__is_instance_of() - `an_instance` is not inherited from class!")
    assert(__is_class(a_class), "__is_instance_of() - `a_class` is not a class!")
    assert(__is_instance(an_instance), "__is_instance_of() - `an_instance` is not an instance!")
    assert(not __is_instance(a_class), "__is_instance_of() - `a_class` can not be an instance!")

    local cls = an_instance.__class
    return __is_subclass_of(cls, a_class)
end

local __file_exist = function(filepath)
    local file = fopen(filepath, "r")
    if file then fclose(file); return true end
    return false
end

local __search_paths = function(filename)
    for path in gmatch(package.path, "([^;]+)") do
        path = gsub(path, "?", filename)
        if __file_exist(path) then
            return path
        end
    end
end

local __implements = function(a_class, filename)
    local path = __search_paths(filename)
    assert(path, "__implements() - file not found: " .. filename)

    local env = setmetatable({}, {
        __index = function(t, k)
            return a_class[k] or _G[k]
        end,
        __newindex = function(t, k, v)
            a_class[k] = v
        end,
    })

    if _VERSION <= "Lua 5.1" then
        setfenv(assert(loadfile(path, "bt")), env)()
    else
        assert(loadfile(path, "bt", env))()
    end

    return a_class
end

local __create_class = function(name, super)
    assert(type(name) == "string", "__create_class() - string expected, got: ".. type(name))

    super = super or classbase

    local a_class = {
        __name  = name,
        __super = super,

        is_instance_of = __is_instance_of,
        is_subclass_of = __is_subclass_of,

        implements = __implements,

        initialize   = function() end,
        uninitialize = function() end,
    }

    setmetatable(a_class, {
        __index = super,
        __metatable = super,
        __call = function(_, ...) return a_class:new(...) end,
        __tostring = function()
            return name
        end,
    })

    return a_class
end

class.is = __is_class
class.typeof = __typeof

setmetatable(class, {__call = function(_, name, super) return __create_class(name, super) end})

return class
