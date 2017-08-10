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
    _VERSION     = "v1.0.1",
    _VERBOSE     = 0,
    _SPEC        = 0,
}

local assert = assert
local setmetatable = setmetatable
local getmetatable = getmetatable
local rawget = rawget
local rawset = rawset
local gmatch = string.gmatch
local gsub   = string.gsub
local fopen  = io.open
local fclose = io.close

local _hash_code = 0x0
local _hash_code_generator = function()
    _hash_code = _hash_code + 1
    return _hash_code
end

local _default_alloc = function(aClass)
    local instance = {
        __hashcode = _hash_code_generator(),
        __class    = aClass,
    }

    local meta = {
        __index = function(_, keyname)
            assert(not aClass.static[keyname], "Cannot call static member from instance!")
            return aClass[keyname]
        end,
        __newindex = function(t, keyname, value)
            assert(keyname ~= "static", "'static' is a keyword, please use others instead.")
            rawset(t, keyname, value)
        end,
        __metatable = aClass,   -- fake meta
        __eq = function(self, other)
            return self.__hashcode == other.__hashcode
        end,
        __tostring = function()
            return string.format("classname: %s, hashcode: %s", instance.__name, instance.__hashcode)
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

local _default_dealloc = function(anInstance)
    -- nothing to do
end

local _depth_first_initialize, _bread_first_uninitialize

_depth_first_initialize = function(aClass, anInstance, ...)
    if aClass.__super then
        _depth_first_initialize(aClass.__super, anInstance, ...)
    end
    local initializer = rawget(aClass, "initialize")
    if initializer then
        initializer(anInstance, ...)
    end
end

_bread_first_uninitialize = function(aClass, anInstance)
    local uninitializer = rawget(aClass, "uninitialize")
    if uninitializer then
        uninitializer(anInstance)
    end
    if aClass.__super then
        _bread_first_uninitialize(aClass.__super, anInstance)
    end
end

local classbase = {
    new = function(aClass, ...)
        assert(type(aClass) == "table", "You must use Class:new() instead of Class.new()")

        local instance = aClass:allocate()
        _depth_first_initialize(aClass, instance, ...)
        return instance
    end,

    destroy = function(anInstance)
        assert(type(anInstance) == "table", "You must use Class:destroy() instead of Class.destroy()")

        _bread_first_uninitialize(anInstance.__class, anInstance)
        anInstance:deallocate()
    end,

    allocate = function(aClass, ...)
        if aClass.__alloc then
            return aClass:__alloc()
        end
        return _default_alloc(aClass)
    end,

    deallocate = function(anInstance, ...)
        if anInstance.__dealloc then
            anInstance:__dealloc()
            return
        end
        _default_dealloc(anInstance)
    end,

    default_alloc   = _default_alloc,
    default_dealloc = _default_dealloc,
}

local _get_base_metatable = function(aClassOrAnInstance)
    local basemeta
    local meta = getmetatable(aClassOrAnInstance)
    while meta do
        basemeta = meta
        meta = getmetatable(meta)
    end
    return basemeta
end

local _is_class = function(target)
    return _get_base_metatable(target) == classbase
end

local _typeof = function(target)
    return getmetatable(target)
end

local _is_subclass_of = function(subclass, super)
    assert(_is_class(subclass), "_is_subclass_of() - `subclass` is not a class!")
    assert(_is_class(super), "_is_subclass_of() - `super` is not a class!")
    assert(not subclass.__hashcode, "_is_subclass_of() - `subclass` cannot be an instance!")
    assert(not subclass.__hashcode, "_is_subclass_of() - `super` cannot be an instance!")

    local cls = subclass
    repeat
        if rawget(cls, "__name") == rawget(super, "__name") then
            return true
        end
        cls = cls.__super
    until not cls

    return false
end

local _is_instance_of = function(anInstance, aClass)
    assert(_is_class(anInstance), "_is_instance_of() - `anInstance` is not inherited from class!")
    assert(_is_class(aClass), "_is_instance_of() - `aClass` is not a class!")
    assert(anInstance.__hashcode, "_is_instance_of() - `anInstance` is not an instance!")
    assert(not aClass.__hashcode, "_is_instance_of() - `aClass` can not be an instance!")

    local cls = anInstance.__class
    return _is_subclass_of(cls, aClass)
end

local _file_exist = function(filepath)
    local file = fopen(filepath, "r")
    if file then fclose(file); return true end
    return false
end

local _search_paths = function(filename)
    for path in gmatch(package.path, "([^;]+)") do
        path = gsub(path, "?", filename)
        if _file_exist(path) then
            return path
        end
    end
end

local _implements = function(aClass, filename)
    local path = _search_paths(filename)
    assert(path, "_implements() - file not found: " .. filename)

    setmetatable(aClass.env, {__index = _G})
    assert(loadfile(path, "bt", aClass.env))()
    -- busted will change the behavior of the metatable during testing,
    -- when set the metatable to 'nil', things will get wrong.
    if class._SPEC <= 0 then
        setmetatable(aClass.env, nil)
    end

    return aClass
end

local _create_class = function(name, super)
    assert(type(name) == "string", "_createClas() - string expected, got: ".. type(name))

    local aClass = {
        __name  = name,
        __super = super,

        env = {
            static = setmetatable({}, {__index = super and super.static}),
        },

        is_instance_of = _is_instance_of,
        is_subclass_of = _is_subclass_of,

        implements = _implements,
    }

    setmetatable(aClass, {
        __index = function(_, keyname)
            return rawget(aClass, "env").static[keyname]
                or rawget(aClass, "env")[keyname]
                or (super and super[keyname]
                or classbase[keyname])
        end,
        __metatable = super or classbase,    -- fake meta
        __call = function(_, ...) return aClass:new(...) end,
        __tostring = function()
            return "classname: " .. name
        end,
    })

    return aClass
end

class.is = _is_class
class.typeof = _typeof

setmetatable(class, {__call = function(_, name, super) return _create_class(name, super) end})

return class
