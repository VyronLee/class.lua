local class = require "class"

describe("A class", function()

    describe("created without super class", function()
        it("has the correct class name", function()
            local classA = class("ClassA")
            assert.truthy(classA)
            assert.equal(classA.__name, "ClassA")
        end)
    end)

    describe("created with super class", function()
        local classA = class("ClassA")
        local classB = class("ClassB", classA)

        it("has the correct class name and super class name", function()
            assert.equal(classA.__name, "ClassA")
            assert.equal(classB.__name, "ClassB")
            assert.equal(classB.__super, classA)
            assert.equal(classB.__super.__name, "ClassA")
        end)

        it("has the correct inherite relation", function()
            assert.is_true(classB:isSubClassOf(classA))
        end)
    end)

end)

describe("An object", function()

    describe("instantiated from class", function()
        it("is the instance of it", function()
            local classA = class("ClassA")
            local instance = classA:new()
            assert.is_true(instance:isInstanceOf(classA))
        end)
    end)

    describe("instantiated from class with super class", function()
        it("is the instance both of them", function()
            local classA = class("ClassA")
            local classB = class("ClassB", classA)
            local instance = classB()

            assert.is_true(instance:isInstanceOf(classB))
            assert.is_true(instance:isInstanceOf(classA))
        end)
    end)

end)
