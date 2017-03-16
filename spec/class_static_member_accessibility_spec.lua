local class = require "class"

describe("A static member", function()

    it("can be invoke directly", function()
        local classA = class("ClassA")
        classA.static.width = 5
        classA.static.getWidth = function()
            return 6
        end
        local instance = classA:new()

        assert.equal(classA.width, 5)
        assert.equal(classA:getWidth(), 6)
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
        classA.static.getWidth = function()
            return 6
        end

        assert.equal(classB.width, 5)
        assert.equal(classB:getWidth(), 6)
        assert.has_error(function()
            local instance = classB:new()
            print(instance.width)
        end)
    end)

end)
