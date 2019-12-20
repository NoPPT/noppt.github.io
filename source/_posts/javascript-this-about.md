---
title: JavaScript this 和对象原型
date: 2019-1-3 20:40:09
tags:
  - JavaScript
categories: JavaScript
---

# this

this 实际上是在函数被调用时发生的绑定，它指向什么完全取决于函数在哪里被调用。

函数调用时应用了 this 的默认绑定，因此 this 指向全局对象。如果使用严格模式（strict mode），那么全局对象将无法使用默认绑定，因此 this 会绑定到 undefined，需要注意的是指向与函数默认绑定与函数的定义位置是否是严格模式有关，与函数调用时是否严格模式无关。

## 绑定规则

### 隐式绑定

当函数引用有上下文对象时，隐式绑定规则会把函数调用中的 this 绑定到这个上下文对象。

### 隐式丢失

一个最常见的 this 绑定问题就是被隐式绑定的函数会丢失绑定对象，也就是说它会应用默认绑定，从而把 this 绑定到全局对象或者 undefined 上。

<!-- more -->

```js
function foo() {
  console.log(this.a);
}

var obj = {
  a: 2,
  foo: foo
};
var bar = obj.foo; // 函数别名!
var a = "oops, global"; // a是全局对象的属性
bar(); // "oops, global"
```

虽然 bar 是 obj.foo 的一个引用，但是实际上，它引用的是 foo 函数本身，因此此时的 bar() 其实是一个不带任何修饰的函数调用，因此应用了默认绑定。尤其注意函数的“间接引用”一旦目标函数被其他对象引用，其上下文就指向目标函数本身的调用时的词法作用域.

### 显示绑定

可以使用函数的 call(..) 和 apply(..)方法，JavaScript 提供的绝大多数函数以及你自己创建的所有函数都可以使用 call(..) 和 apply(..) 方法。

**装箱** 如果传入了一个原始值（字符串类型，布尔类型或者数字类型）来当做 this 的绑定对象，这个原始值会被转换成它的对象形式（也就是 new String(..）、 new Boolean(..) 或者 new Number(..))，称为“装箱”。

**硬绑定**

创建函数 fun，并调用了 fun 的 call 函数，因此强制把函数本体绑定到 call 传入的对象上，这种绑定是一种显示的强制绑定，称为硬绑定。

es5 提供了内置的方法 `Function.prototype.bind`, bind(..)会返回一个硬编码的新函数，它会把参数设置为 this 的上下文并调用原始函数。

**API 调用的上下文**

第三方库的许多函数，以及 JavaScript 语言和宿主环境中许多新的内置函数，都提供了一个可选的参数，通常被称为 “上下文”(context)，其作用和 bind(..) 一样，确保你的回掉函数使用指向的 this。

`[1, 2, 3].forEach( foo, obj)` 调用 foo(..) 时把 this 绑定到 obj

**new 绑定**

包括内置对象函数在内的所有函数都可以用 new 来调用，这种函数调用被称为构造函数调用。这里一个重要但是非常细微的区别：实际上并不存在所谓的“构造函数”，只有对于函数的“构造函数”。

发生构造函数调用时，会自动执行下面的操作：

1. 创建（或者说构造）一个全新的对象
2. 这个新对象会被执行 [[ 原型 ]] 连接
3. 这个新对象会绑定到函数调用的 this
4. 如果函数没有返回其他对象，那么 new 表达式中的函数调用会自动返回这个新对象

**优先级**

显示绑定优先级比隐式绑定优先级高。
new 绑定优先级比隐式绑定优先级高。
new 绑定优先级比显示绑定优先级高。(新创建的 this 替换硬绑定的 this)

判断 this：

1. 函数是否在 new 中调用（new 绑定）？如果是的话 this 绑定的是新创建的对象。
2. 函数是否通过 call、apply（显示绑定）或者硬绑定调用？如果是的话，this 绑定的是指定的对象。
3. 函数是否在某个上下文对象中调用（隐式绑定）？如果是的话，this 绑定的是那个上下文对象
4. 如果都不是的话，就使用默认绑定，如果在严格模式下，就绑定到 undefined,否则绑定到全局对象

**被忽略的 this**

如果把 null 或者 undefined 作为 this 的绑定对象传入 call、apply 或者 bind，这些值在调用时会被忽略，实际应用的是默认绑定规则

**更安全的 this**

传入一个特殊对象，创建一个“DMZ”（demilitarized zone，非军事区）对象---它就是一个空的非委托的对象。在 JavaScript 中创建一个空对象最简单的方法都是 Object.create(null), Ojbect.create(null)和{}很像，但是并不会创建 Objet.prototype 这个委托，所以他比 {} “更空”.

**软绑定**

硬绑定会大大降低函数的灵活性，使用硬绑定之后就无法使用隐式绑定或者显示绑定来修改 this，如果可以给默认绑定指定一个全局对象和 undefined 以外的值，那就可以实现和硬绑定相同的效果，同时保留隐式绑定或者显示绑定修改 this 的能力。此时可以使用软绑定 softBind(..)

```js
function foo() {
  console.log("name: " + this.name);
}
var obj = { name: "obj" },
  obj2 = { name: "obj2" },
  obj3 = { name: "obj3" };
var fooOBJ = foo.softBind(obj);
fooOBJ(); // name: obj
obj2.foo = foo.softBind(obj);
obj2.foo(); // name: obj2 <---- 看!!!
fooOBJ.call(obj3); // name: obj3 <---- 看!
setTimeout(obj2.foo, 10);
// name: obj <---- 应用了软绑定
```

箭头函数不使用 this 的四种标准规则，而是根据外层(函数或者全局)作用域来决 定 this。
