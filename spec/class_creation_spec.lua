local class = require "class"

describe("A class", function()

    describe("created without super class", function()
        it("has the correct class name", function()
            local classA = class("ClassA")
            assert.truthy(classA)
            assert.equal("ClassA", classA:classname())
            assert.equal("ClassA", tostring(classA))
        end)
    end)

    describe("created with super class", function()
        it("has the correct class name and super class name", function()
            local classA = class("ClassA")
            local classB = class("ClassB", classA)
            assert.equal("ClassA", classA:classname())
            assert.equal("ClassB", classB:classname())
            assert.equal(classB:super(), classA)
            assert.equal(classB:super():classname(), "ClassA")
        end)

        it("has the correct inherite relation", function()
            local classA = class("ClassA")
            local classB = class("ClassB", classA)
            local classC = class("ClassC", classB)
            local classD = class("ClassD")
            assert.is_true(classB:is_subclass_of(classA))
            assert.is_true(classC:is_subclass_of(classA))
            assert.is_false(classD:is_subclass_of(classA))
        end)
    end)
end)

describe("An object", function()

    it("can use 'tostring' to output it's hashcode", function()
        local classA = class("ClassA")
        local instanceA = classA:create()
        local instanceB = classA:create()
        assert.equal("ClassA: 0x1", tostring(instanceA))
        assert.equal("ClassA: 0x2", tostring(instanceB))
    end)

    describe("instantiated from class", function()
        it("is the instance of it", function()
            local classA = class("ClassA")
            local instance = classA:create()
            assert.is_true(instance:is_instance_of(classA))
        end)
    end)

    describe("instantiated from class with super class", function()
        it("is the instance both of them", function()
            local classA = class("ClassA")
            local classB = class("ClassB", classA)
            local instance = classB()

            assert.is_true(instance:is_instance_of(classB))
            assert.is_true(instance:is_instance_of(classA))
        end)
    end)

    it("and another can use operator '=' determine equals or not", function()
        local classA = class("classA")
        local instance1 = classA()
        local instance2 = classA()

        for k,v in pairs(instance1) do
            instance2[k] = v
        end
        assert.is_true(instance1 == instance2)
    end)

end)
