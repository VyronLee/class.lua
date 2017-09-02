local class = require "class"

describe("A instance", function()

    it("can use `typeof` method to decide it's type", function()
        local classA = class("ClassA")
        local classB = class("ClassB")
        local instanceA = classA()
        assert.is_true(class.typeof(instanceA) == classA)
        assert.is_false(class.typeof(instanceA) == classB)
    end)

end)
