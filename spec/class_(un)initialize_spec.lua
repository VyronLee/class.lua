local class = require "class"

describe("An instance", function()

    local classA = class("ClassA")
    classA.initialize = function(self) print "classA initialize" end
    classA.uninitialize = function(self) print "classA uninitialize" end

    local classB = class("ClassB", classA)
    classB.initialize = function(self) print "classB initialize" end
    classB.uninitialize = function(self) print "classB uninitialize" end

    it("it's initialize method will be invoke after new()", function()
        local initialize_messages = {}
        _G.print = function(msg)
            table.insert(initialize_messages, msg)
        end

        classB:new()

        local initialize_messages_expect = {
            "classA initialize",
            "classB initialize",
        }

        assert.are.same(initialize_messages, initialize_messages_expect)
    end)

    it("it's uninitialize method will be invoke after destroy()", function()
        local instanceB = classB:new()

        local uninitialize_messages = {}
        _G.print = function(msg)
            table.insert(uninitialize_messages, msg)
        end

        instanceB:destroy()

        local uninitialize_messages_expect = {
            "classB uninitialize",
            "classA uninitialize",
        }

        assert.are.same(uninitialize_messages, uninitialize_messages_expect)
    end)

    it("allow none initialize/uninitialize methods", function()
        local classC = class("ClassC", classB)

        local initialize_messages = {}
        _G.print = function(msg)
            table.insert(initialize_messages, msg)
        end

        classC:new()

        local initialize_messages_expect = {
            "classA initialize",
            "classB initialize",
        }

        assert.are.same(initialize_messages, initialize_messages_expect)

    end)
end)
