# lua-class

[![Build Status](https://travis-ci.org/VyronLee/class.lua.svg?branch=master)](https://travis-ci.org/VyronLee/class.lua)
[![Coverage Status](https://coveralls.io/repos/github/VyronLee/class.lua/badge.svg?branch=master)](https://coveralls.io/github/VyronLee/class.lua?branch=master)
[![License](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)](LICENSE)

一个用于实现面向对象编程思想的Lua类模块。

# Features

1. 该模块以C++类为原型，进行相关行为的模拟：

|   函数名  |     功能说明       |
|-----------|--------------------|
| new       | 相当于c++中的new，用于新建一个对象|
| destroy   | 相当于c++中的delete, 用于删除一个对象|
| initialize| 相当于构造函数，使用new生成对象后会自动调用。如有继承关系，会先调用父类的initialize，再调用子类的initialize|
| unintialize|相当于析构函数，使用destroy删除对象后会自动调用。如有继承关系，会先调用子类的uninitialize，再调用父类的uninitialize|

2. 提供两个自定义“metamethod”：`__alloc`以及`__dealloc`，
使用者可制定自己的对象生成与销毁处理逻辑，该功能对于实现“对象池”十分方便。

3. 提供`is_subclass_of`与`is_instance_of`函数，分别用于检测是否为指定类的子类或者实例。

4. 提供`implements`能力，可以从另一个文件加载类的具体实现，类似于'.h'与'.c/cpp'的关系

# Installation

把`class.lua`文件拷贝到工程中即可使用。

# Usage

定义一个类：

``` lua
local class = require("class")

local ClassA = class("ClassA")              -- 无继承关系
local ClassB = class("ClassB", ClassA)      -- 继承ClassA

function ClassA:initialize()
    print("Class:initialize()")
end

function ClassA:uninitialize()
    print("Class:uninitialize()")
end

...

```

实例化与显式销毁对象：

``` lua
local instanceA = ClassA:new()
local instanceB = ClassB:new()

instanceA:destroy()
instanceB:destroy()
```

加载类具体实现：

file: decl/classA.lua

``` lua
local classA = class("classA"):implements("impl/classA.impl")

return classA
```

file: impl/classA.impl.lua

``` lua
function initialize(self)
    print("initializer in classA.impl!")
end

function uninitialize(self)
    print("uninitializer in classA.impl!")
end

```

# UnitTest

本工程使用[busted](http://olivinelabs.com/busted/)作为单元测试框架，需要从luarocks进行安装。安装完毕后在工程目录执行：

``` shell
busted -v
```

即可。

# License

MIT License.


