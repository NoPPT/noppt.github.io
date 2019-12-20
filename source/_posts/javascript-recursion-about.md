---
title: JavaScript 递归与尾递归
date: 2018-12-18 19:43:10
tags:
  - JavaScript
categories: JavaScript
---

## 递归

程序调用自身的编程技巧称为递归(recursion)。

```js
function factorial(n) {
  if (n == 1) return n;
  return n * factorial(n - 1);
}

console.log(factorial(5)); // 5 * 4 * 3 * 2 * 1 = 120
```

### 条件

- 子问题须与原始问题为同样的事，且更为简单；
- 不能无限制地调用本身，须有个出口，化简为非递归状况处理。

<!-- more -->

### 尾调用

当执行一个函数的时候，就会创建一个执行上下文，并且压入执行上下文栈，当函数执行完毕的时候，就会将函数的执行上下文从栈中弹出。

试着对阶乘函数分析执行的过程，我们会发现，JavaScript 会不停的创建执行上下文压入执行上下文栈，对于内存而言，维护这么多的执行上下文也是一笔不小的开销呐！那么，我们该如何优化呢？

**尾调用**，是指函数内部的最后一个动作是函数调用。该调用的返回值，直接返回给函数。

```js
// 尾调用
function f(x) {
  return g(x);
}
// 非尾调用
function f(x) {
  return g(x) + 1;
}
```

模拟执行上下文栈

```js
ECStack = [];

// 尾调用
ECStack.push(<f> functionContext);

ECStack.pop();

ECStack.push(<g> functionContext);

ECStack.pop();

// 非尾调用
ECStack.push(<f> functionContext);

ECStack.push(<g> functionContext);

ECStack.pop();

ECStack.pop();
```

尾调用函数执行时，调用了一个函数，在原来的的函数执行完毕，执行上下文会被弹出，执行上下文栈中相当于只多压入了一个执行上下文。然而非尾调用函数，就会创建多个执行上下文压入执行上下文栈。

**尾递归**：函数调用自身，称为递归。如果尾调用自身，就称为尾递归。
