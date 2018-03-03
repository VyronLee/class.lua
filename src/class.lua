------------------------------------------------------------------------
--        File:  class.lua
--       Brief:  Object Orientation for Lua
--
--      Author:  VyronLee, lwz_jz@hotmail.com
--
--    Modified:  2018-03-03 18:09
--   Copyright:  Copyright (c) 2018, VyronLee, Apache License 2.0
--======================================================================

local class = {
    _AUTHOR      = "VyronLee (lwz_jz@hotmail.com)",
    _LICENSE     = "Apache License 2.0",
    _VERSION     = "v1.0.2",
}

local assert = assert
local load = load
local loadfile = loadfile
local setmetatable = setmetatable
local rawget = rawget

local gmatch = string.gmatch
local gsub   = string.gsub
local format = string.format
local dump   = string.dump

local fopen  = io.open
local fclose = io.close

local __hash_code = 0x0
local __hash_code_generator = function()
    __hash_code = __hash_code + 1
    return __hash_code
end

local __CLASS_IDENTITY = "__class__"

local __instance_equal_comparator = function(l, r)
    return l.__hashcode == r.__hashcode
end

local __instance_less_than_comparator = function(l, r)
    return l.__hashcode < r.__hashcode
end

local __instance_less_equal_comparator = function(l, r)
    return l.__hashcode <= r.__hashcode
end

local __instance_stringify = function(o)
    return format("%s: 0x%X", o.__name, o.__hashcode)
end

local __default_alloc = function(a_class)
    local instance = {
        __hashcode = __hash_code_generator(),
        __class    = a_class,
    }
    setmetatable(instance, a_class)

    return instance
end

local __default_dealloc = function(an_instance)
    -- nothing to do
end

local __depth_first_initialize, __bread_first_finalize

__depth_first_initialize = function(a_class, an_instance, ...)
    if a_class.__super then
        __depth_first_initialize(a_class.__super, an_instance, ...)
    end
    local initializer = rawget(a_class, "initialize")
    if initializer then
        initializer(an_instance, ...)
    end
end

__bread_first_finalize = function(a_class, an_instance)
    local finalizer = rawget(a_class, "finalize")
    if finalizer then
        finalizer(an_instance)
    end
    if a_class.__super then
        __bread_first_finalize(a_class.__super, an_instance)
    end
end

local classbase = {
    create = function(a_class, ...)
        assert(type(a_class) == "table", "You must use Class:create() instead of Class.create()")

        local instance = a_class:allocate()
        __depth_first_initialize(a_class, instance, ...)
        return instance
    end,

    destroy = function(an_instance)
        assert(type(an_instance) == "table", "You must use Class:destroy() instead of Class.destroy()")

        __bread_first_finalize(an_instance.__class, an_instance)
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

    super = function() end,

    classname = function()
        return __CLASS_IDENTITY
    end,

    __name = __CLASS_IDENTITY,
}

local __get_super_base

__get_super_base = function(target)
    if target.__hashcode then
        return __get_super_base(target.__class)
    end
    return target.__super and __get_super_base(target.__super) or target
end

local __is_class = function(target)
    if type(target) ~= "table" then
        return false
    end
    return __get_super_base(target) == classbase
end

local __is_instance = function(target)
    return __is_class(target) and (not not target.__hashcode)
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

local __setfenv = function(chunk, env)
    return load(dump(chunk), nil, "bt", env)
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

local __default_loader = function(filename)
    local path = __search_paths(filename)
    assert(path, "__default_loader() - file not found: " .. filename)
    return assert(loadfile(path, "bt"))
end

local __implements = function(a_class, filename, loader)
    local env = setmetatable({}, {
        __index = function(_, k)
            return k == "self" and a_class or a_class[k] or _G[k]
        end,
        __newindex = function(_, k, v)
            a_class[k] = v
        end,
    })
    assert((setfenv or __setfenv)((loader or __default_loader)(filename), env))()

    return a_class
end

local __create_class = function(name, super)
    assert(type(name) == "string", "__create_class() - string expected, got: ".. type(name))

    super = super or classbase

    local a_class = {}
    a_class.__name  = name
    a_class.__super = super
    a_class.__index = a_class

    a_class.__tostring = __instance_stringify
    a_class.__eq = __instance_equal_comparator
    a_class.__lt = __instance_less_than_comparator
    a_class.__le = __instance_less_equal_comparator

    a_class.is_instance_of = __is_instance_of
    a_class.is_subclass_of = __is_subclass_of

    a_class.implements = __implements

    a_class.initialize  = function() end
    a_class.finalize    = function() end
    a_class.super       = function() return super end
    a_class.classname   = function() return name  end

    local meta = {
        __index = super,
        __metatable = super,
        __call = function(_, ...) return a_class:create(...) end,
        __tostring = function() return name end,
    }
    setmetatable(a_class, meta)

    return a_class
end

class.is_class = __is_class
class.is_instance = __is_instance
class.typeof = __typeof

setmetatable(class, {__call = function(_, name, super) return __create_class(name, super) end})

return class
