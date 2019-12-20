---
title: JavaScript 隐式转换
date: 2019-1-31 21:42:14
tags:
  - JavaScript
categories: JavaScript
---

下面这种写法的作用是将当前时间转换为时间戳。原理？

```js
var now = +new Date();
```

<!-- more -->

## ECMAScript 规范

### 一元 `+` 运算符

> :将其操作数转换为 Number 类型并反转其正负。注意负的 `+0` 产生 `-0`，负的 `-0`产生 `+0`。

产生式 UnaryExpression : - UnaryExpression 按照下面的过程执行 :

1. 令 expr 为解释执行 UnaryExpression 的结果 .
1. 令 oldValue 为 ToNumber(GetValue(expr)).
1. 如果 oldValue is NaN ，return NaN.
1. 返回 oldValue 取负（即，算出一个数字相同但是符号相反的值）的结果。

`+new Date()` 相当于 `ToNumber(new Date())`

### ToNumber()

ToNumber 运算符根据下表规则将参数值转换为数值类型的值

| 输入类型  | 结果                                                                            |
| --------- | ------------------------------------------------------------------------------- |
| Undefined | NaN                                                                             |
| Null      | 0                                                                               |
| Boolean   | true => 1, false => +0                                                          |
| Number    | 结果等于输入的参数(不转换)                                                      |
| String    | 参照注释                                                                        |
| Object    | 1. 原始值为 ToPrimitive(输入参数，暗示数值类型) <br /> 2. 返回 ToNumber(原始值) |

### ToPrimitive

ToPrimitive 运算符接受一个值，和一个可选的期望类型作参数。ToPrimitive 运算符把其值参数转换为非对象类型。如果对象可以被转换为不止一种原语类型，会转换为传入的期望类型参数。

| 输入类型  | 结果                                                                                               |
| --------- | -------------------------------------------------------------------------------------------------- |
| Undefined | 结果等于输入的参数(不转换)                                                                         |
| Null      | 结果等于输入的参数(不转换)                                                                         |
| Boolean   | 结果等于输入的参数(不转换)                                                                         |
| Number    | 结果等于输入的参数(不转换)                                                                         |
| String    | 结果等于输入的参数(不转换)                                                                         |
| Object    | 返回该对象的默认值。对象默认值由传入的期望类型作为 hint 参数调用对象内部方法 [[DefaultValue]] 得到 |

`ToPrimitive(obj,preferredType)`

JS 引擎内部转换为原始值 ToPrimitive(obj,preferredType)函数接受两个参数，第一个 obj 为被转换的对象，第二个
preferredType 为希望转换成的类型（默认为空，接受的值为 Number 或 String）

在执行 ToPrimitive(obj,preferredType)时如果第二个参数为空并且 obj 为 Date 的事例时，此时 preferredType 会被设置为 String，其他情况下 preferredType 都会被设置为 Number 如果 preferredType 为 Number，ToPrimitive 执行过程如下：

1. 如果 obj 为原始值，直接返回；
1. 否则调用 obj.valueOf()，如果执行结果是原始值，返回之；
1. 否则调用 obj.toString()，如果执行结果是原始值，返回之；
1. 否则抛异常。

如果 preferredType 为 String，将上面的第 2 步和第 3 步调换，即：

1. 如果 obj 为原始值，直接返回；
1. 否则调用 obj.toString()，如果执行结果是原始值，返回之；
1. 否则调用 obj.valueOf()，如果执行结果是原始值，返回之；
1. 否则抛异常。

- toString 用来返回对象的字符串表示
- valueOf 方法返回对象的原始值，可能是字符串、数值或 bool 值等，看具体的对象。
- 原始值指的是['Null','Undefined','String','Boolean','Number','Symbol']6 种基本数据类型之一
