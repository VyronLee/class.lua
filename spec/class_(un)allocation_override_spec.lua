local class = require "class"

describe("A class", function()
    it("can declare it's own allocate/deallocate method", function()
        local pool = {}     -- object pool.
        local classA = class("ClassA")
        classA.__alloc = function(self)
            if #pool > 0 then
                return table.remove(pool, 1)
            end
            return self:default_alloc()
        end
        classA.__dealloc = function(self)
            table.insert(pool, self)
        end

        local instanceOld = classA()
        instanceOld:destroy()

        local instanceNew = classA()

        assert.same(instanceOld, instanceNew)
    end)
end)
