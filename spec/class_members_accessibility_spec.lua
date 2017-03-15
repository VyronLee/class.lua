local class = require "class"

describe("A object instantiated from class", function()

    it("can access methods or members", function()
        local classA = class("ClassA")
        classA.width = 1
        classA.getWidth = function(self)
            return self.width
        end
        local instance = classA:new()
        assert.equal(instance:getWidth(), 1)
    end)

    it("can access methods or memebers from super class", function()
        local classA = class("ClassA")
        local classB = class("ClassA", classA)
        local classC = class("ClassC", classB)

        classA.width  = 1
        classA.height = 2
        classA.getWidth = function(self) return self.width end

        classB.width  = 3   -- override memeber `width`

        classC.getHeight = function(self) return self.height end

        local instanceC = classC:new()

        assert.equal(instanceC:getWidth(), 3)
        assert.equal(instanceC:getHeight(), 2)
    end)

end)
