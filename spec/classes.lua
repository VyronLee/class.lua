local class = require "class"
local classA = class("ClassA"):implements("spec/classA-impl")
local classB = class("ClassB", classA)

return {
    classA = classA,
    classB = classB,
}
