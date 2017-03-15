local class = require "class"

describe("An instance", function()
    it("should be dealloc when there is non-reference", function()
        class._VERBOSE = 1      -- enable verbose print

        local gc_messages = {}
        _G.print = function(msg)   -- redirect global `print` function
            table.insert(gc_messages, msg)
        end

        local classA = class("ClassA")
        local classB = class("ClassB", classA)

        local instanceA = classA()
        local instanceB = classB()
        instanceA = nil
        instanceB = nil
        collectgarbage("collect")

        local gc_messages_expect = {
            "An instance has allocated, classname: ClassA, hashcode: 1",
            "An instance has allocated, classname: ClassB, hashcode: 2",
            "An instance has collected, classname: ClassB, hashcode: 2",
            "An instance has collected, classname: ClassA, hashcode: 1",
        }
        assert.are.same(gc_messages_expect, gc_messages)
    end)
end)
