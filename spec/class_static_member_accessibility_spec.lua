local class = require "class"

describe("A static member", function()

    it("can be invoke directly", function()
        local classA = class("ClassA")
        classA.static.width = 5
        function classA.static.getWidth()
            return 6
        end
        local instance = classA:new()

        assert.equal(5, classA.width)
        assert.equal(6, classA:getWidth())
        assert.has_error(function()
            print(instance.width)
        end)
        assert.has_error(function()
            print(instance:getWidth())
        end)
    end)

    it("can be invoke even inherited from super class", function()
        local classA = class("ClassA")
        local classB = class("ClassB", classA)

        classA.static.width = 5
        function classA.static.getWidth()
            return 6
        end

        assert.equal(5, classB.width)
        assert.equal(6, classB:getWidth())
        assert.has_error(function()
            local instance = classB:new()
            print(instance.width)
        end)
    end)
end)

describe("An instance", function()
    it("cannot assign new value with key 'static'", function()
        local classA = class("ClassA")
        local instance = classA()

        assert.has_error(function()
            instance.static = "new assign value"
        end)
    end)

    it("cannot call it's static member/methods directly", function()
        local classA = class("ClassA")
        classA.static.s_value = "s_value"

        local instance = classA()
        local s_value
        assert.has.no_error(function() s_value = classA.s_value end)
        assert.has_error(function() s_value = instance.s_value end)
    end)
end)
