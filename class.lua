--------------------------------------------------------------
--       @file  class.lua
--      @brief  Object Orientation for Lua
--
--     @author  VyronLee, lwz_jz@hotmail.com
--
--   @internal
--    Modified  2017-03-13 18:19
--   Copyright  Copyright (c) 2017, VyronLee
--============================================================

local class = {
    _AUTHOR      = "VyronLee (lwz_jz@hotmail.com)",
    _LICENSE     = "MIT License",
    _VERSION     = "v1.0.0",
    _VERBOSE     = 0,
}

local _hashCode = 0x0
local _hashCodeGenerator = function()
    _hashCode = _hashCode + 1
    return _hashCode
end

local _defaultAlloc = function(aClass)
    local instance = {
        __hashCode = _hashCodeGenerator(),
        __class    = aClass,
        static     = {},
    }

    local meta = {
        __index = function(_, keyname)
            assert(not aClass.static[keyname], "Cannot call static member from instance!")
            return aClass[keyname]
        end,
        __metatable = aClass,   -- fake meta
        __eq = function(self, other)
            return self.__hashCode == other.__hashCode
        end,
        __tostring = function()
            return string.format("classname: %s, hashcode: %s", instance.__name, instance.__hashCode)
        end,
        __gc = function(instance)
            if class._VERBOSE >= 1 then
                print("An instance has collected, " .. tostring(instance))
            end
        end
    }
    setmetatable(instance, meta)

    if class._VERBOSE >= 1 then
        print("An instance has allocated, " .. tostring(instance))
    end

    return instance
end

local _defaultDealloc = function(anInstance)
    -- nothing to do
end

local _depthFirstInitialize, _breadthFirstUninitialize

_depthFirstInitialize = function(aClass, anInstance, ...)
    if aClass.__super then
        _depthFirstInitialize(aClass.__super, anInstance, ...)
    end
    aClass.initialize(anInstance, ...)
end

_breadthFirstUninitialize = function(aClass, anInstance)
    aClass.uninitialize(anInstance)
    if aClass.__super then
        _breadthFirstUninitialize(aClass.__super, anInstance)
    end
end

local classbase = {
    new = function(aClass, ...)
        assert(type(aClass) == "table", "You must use Class:new() instead of Class.new()")

        local instance = aClass:allocate()
        _depthFirstInitialize(aClass, instance, ...)
        return instance
    end,

    destroy = function(anInstance)
        assert(type(anInstance) == "table", "You must use Class:destroy() instead of Class.destroy()")

        _breadthFirstUninitialize(anInstance.__class, anInstance)
        anInstance:deallocate()
    end,

    allocate = function(aClass, ...)
        if aClass.__alloc then
            return aClass:__alloc()
        end
        return _defaultAlloc(aClass)
    end,

    deallocate = function(anInstance, ...)
        if anInstance.__dealloc then
            anInstance:__dealloc()
            return
        end
        _defaultDealloc(anInstance)
    end,

    initialize   = function() end,
    uninitialize = function() end,

    defaultAlloc   = _defaultAlloc,
    defaultDealloc = _defaultDealloc,
}

local _getBaseMetatable = function(aClassOrAnInstance)
    local basemeta
    local meta = getmetatable(aClassOrAnInstance)
    while meta do
        basemeta = meta
        meta = getmetatable(meta)
    end
    return basemeta
end

local _isSubClassOf = function(subclass, super)
    assert(_getBaseMetatable(subclass) == classbase, "_isSubClassOf() - `subclass` is not a class!")
    assert(_getBaseMetatable(super) == classbase, "_isSubClassOf() - `super` is not a class!")
    assert(not subclass.__hashCode, "_isSubClassOf() - `subclass` cannot be an instance!")
    assert(not subclass.__hashCode, "_isSubClassOf() - `super` cannot be an instance!")

    local cls = subclass
    repeat
        if rawget(cls, "__name") == rawget(super, "__name") then
            return true
        end
        cls = cls.__super
    until not cls

    return false
end

local _isInstanceOf = function(anInstance, aClass)
    assert(_getBaseMetatable(anInstance) == classbase, "_isInstanceOf() - `anInstance` is not inherited from class!")
    assert(_getBaseMetatable(aClass) == classbase, "_isInstanceOf() - `aClass` is not a class!")
    assert(anInstance.__hashCode, "_isInstanceOf() - `anInstance` is not an instance!")
    assert(not aClass.__hashCode, "_isInstanceOf() - `aClass` can not be an instance!")

    local cls = anInstance.__class
    return _isSubClassOf(cls, aClass)
end

local _createClass = function(name, super)
    local aClass = {
        __name  = name,
        __super = super,

        static  = {},

        isInstanceOf = _isInstanceOf,
        isSubClassOf = _isSubClassOf,
    }

    setmetatable(aClass.static, {
        __index = super and super.static,
    })

    setmetatable(aClass, {
        __index = function(_, keyname)
            return rawget(aClass.static, keyname) or (super and super[keyname] or classbase[keyname])
        end,
        __metatable = super or classbase,    -- fake meta
        __call = function(...) return aClass:new(...) end,
    })

    return aClass
end

setmetatable(class, {__call = function(_, name, super) return _createClass(name, super) end})

return class
