local class = require "class"

describe("A class", function()
    it("can load it's implement from other file", function()
        local classA = class("ClassA")
        assert.has.no_error(classA:implements("spec/classA-impl"))

        local instance = classA()
        assert.equal(6, instance.number6)
        assert.equal(7, classA.number_7())
        assert.equal(49, classA:pow_2_of_7())
    end)
end)
