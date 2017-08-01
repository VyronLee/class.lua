require "class"._SPEC = 1

describe("A class", function()

    describe("created without super class", function()
        it("has the correct class name", function()
            local classA = require "spec/classes".classA
            assert.truthy(classA)
            assert.equal("ClassA", classA.__name)
        end)
    end)

    describe("created with super class", function()
        it("has the correct class name and super class name", function()
            local classA = require "spec/classes".classA
            local classB = require "spec/classes".classB
            assert.equal("ClassA", classA.__name)
            assert.equal("ClassB", classB.__name)
            assert.equal(classB.__super, classA)
            assert.equal(classB.__super.__name, "ClassA")
        end)

        it("has the correct inherite relation", function()
            local classA = require "spec/classes".classA
            local classB = require "spec/classes".classB
            assert.is_true(classB:is_subclass_of(classA))
        end)

        it("can load it's implementation from another file", function()
            local classA = require "spec/classes".classA
            assert.not_nil(classA.number6)
        end)
    end)
end)

describe("An object", function()

    describe("instantiated from class", function()
        it("is the instance of it", function()
            local classA = require "spec/classes".classA
            local instance = classA:new()
            assert.is_true(instance:is_instance_of(classA))
        end)
    end)

    describe("instantiated from class with super class", function()
        it("is the instance both of them", function()
            local classA = require "spec/classes".classA
            local classB = require "spec/classes".classB
            local instance = classB()

            assert.is_true(instance:is_instance_of(classB))
            assert.is_true(instance:is_instance_of(classA))
        end)
    end)

end)
