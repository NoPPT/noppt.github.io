---
title: JavaScript call 和 apply 方法区别和使用场景
date: 2018-11-3 12:34:44
tags:
  - JavaScript
categories: JavaScript
---

# Function.prototype.call()

call() 方法在使用一个指定的 this 值和若干个指定的参数值的前提下调用某个函数或方法。

```js
function.call(thisArg, arg1, arg2, ...)
```

`thisArg` 可选参数，函数运行时指定的 this 值。需要注意的是，指定的 this 值并不一定是该函数执行时真正的 this 值，如果这个函数处于非严格模式下，则指定为 null 和 undefined 的 this 值会自动指向全局对象(浏览器中就是 window 对象)，同时值为原始值(数字，字符串，布尔值)的 this 会指向该原始值的自动包装对象。

`arg1, arg2, ...` 指定的参数列表。

## 使用场景

### 调用父构造函数

通过调用父构造函数的 call 方法来实现继承

### 调用匿名函数

为匿名函数指定 this，并传递参数。

### 调用函数并且指定上下文的'this'

### 调用函数并且不传任何参数

如果这个函数处于非严格模式下，则指定为 null 和 undefined 的 this 值会自动指向全局对象(浏览器中就是 window 对象)，严格模式下不传任何参数时 this 为 undefined。

<!-- more -->

# Function.prototype.apply()

```js
function.apply(thisArg, [argsArray])
```

`thisArg` 同上

`argsArray` 参数数组

## 使用场景

### 数组添加到另一个数组

```
var array = ['a', 'b'];
var elements = [0, 1, 2];
array.push.apply(array, elements);
console.info(array); // ["a", "b", 0, 1, 2]
```

### 内置函数

```
// min/max number in an array
var numbers = [5, 6, 2, 3, 7];

// using Math.min/Math.max apply
var max = Math.max.apply(null, numbers);
// This about equal to Math.max(numbers[0], ...)
// or Math.max(5, 6, ...)
```

需要注意的是，如果参数超过原函数参数数量，一些引擎会报错，或者从前到后取到需要的参数数量。如果数组数量过大，可以考虑 for 循环指定数量区间调用。

### 调用函数实现 constructors

```js
// Object.create()
Function.prototype.construct = function(aArgs) {
  var oNew = Object.create(this.prototype);
  this.apply(oNew, aArgs);
  return oNew;
};

// Object.__proto__
Function.prototype.construct = function(aArgs) {
  var oNew = {};
  oNew.__proto__ = this.prototype;
  this.apply(oNew, aArgs);
  return oNew;
};

// closures
Function.prototype.construct = function(aArgs) {
  var fConstructor = this,
    fNewConstr = function() {
      fConstructor.apply(this, aArgs);
    };
  fNewConstr.prototype = fConstructor.prototype;
  return new fNewConstr();
};

// Function constructor
Function.prototype.construct = function(aArgs) {
  var fNewConstr = new Function("");
  fNewConstr.prototype = this.prototype;
  var oNew = new fNewConstr();
  this.apply(oNew, aArgs);
  return oNew;
};
```

# 区别

只有一个区别，就是 `call()` 方法接受的是若干个参数的列表，而 `apply()` 方法接受的是一个包含多个参数的数组。

# 模拟实现

1. 将函数设为对象的属性
1. 执行该函数
1. 删除该函数
1. 给定参数执行函数
1. this 参数
1. 函数返回值

## call()

```js
Function.prototype.call2 =
  Function.prototype.call ||
  function(context) {
    var context = context || window;
    context.fn = this;

    var args = [];
    for (var i = 1, len = arguments.length; i < len; i++) {
      args.push("arguments[" + i + "]");
    }

    var result = eval("context.fn(" + args + ")");

    delete context.fn;
    return result;
  };

// es6 版本
Function.prototype.call = function(context) {
  var context = context || window;
  context.fn = this;
  var args = Array.prototype.slice.call(arguments, 1);
  var result = context.fn(...args);
  delete context.fn;
  return result;
};
```

## apply()

```js
Function.prototype.apply2 =
  Function.prototype.apply ||
  function(context, arr) {
    var context = Object(context) || window;
    context.fn = this;

    var result;
    if (!arr) {
      result = context.fn();
    } else {
      var args = [];
      for (var i = 0, len = arr.length; i < len; i++) {
        args.push("arr[" + i + "]");
      }
      result = eval("context.fn(" + args + ")");
    }

    delete context.fn;
    return result;
  };
```

上述实现赋值当前函数给指定 this 的 context.fn 属性，存在属性覆盖问题，解决方式是通过遍历给定一个不存在的名字。

```js
var id = 0;
while (context[id]) {
  id++;
}
context[id] = this;

// 或 es6 Symbol()
Function.prototype.call2 = function(context, ...args) {
  context = context || window;
  let fn = Symbol();
  context[fn] = this;
  var result = context[fn](...args);
  Reflect.deleteProperty(context, fn);
  return result;
};
```

[1]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/call
[2]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/apply
