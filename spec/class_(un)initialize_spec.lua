local class = require "class"

describe("An instance", function()

    local classA = class("ClassA")
    classA.initialize = function(self) print "classA initialize" end
    classA.finalize = function(self) print "classA finalize" end

    local classB = class("ClassB", classA)
    classB.initialize = function(self) print "classB initialize" end
    classB.finalize = function(self) print "classB finalize" end

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

    it("it's finalize method will be invoke after destroy()", function()
        local instanceB = classB:new()

        local finalize_messages = {}
        _G.print = function(msg)
            table.insert(finalize_messages, msg)
        end

        instanceB:destroy()

        local finalize_messages_expect = {
            "classB finalize",
            "classA finalize",
        }

        assert.are.same(finalize_messages, finalize_messages_expect)
    end)

    it("allow none initialize/finalize methods", function()
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
