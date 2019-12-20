---
title: JavaScript 数组乱序算法
date: 2018-10-20 09:30:55
tags:
  - JavaScript
categories: JavaScript
---

## 实现方式 - Math.random

```js
var values = [1, 2, 3, 4, 5];

values.sort(function() {
  return Math.random() - 0.5;
});

console.log(values);
```

使用默认 sort 方法，随机返回升序或降序排序，最终得到一个随机数组。

### 存在的问题

并非完美随机，如果以数组最后一个值出现的概率来讲，存在概率相差较大的情况。

### 问题原因

[v8 Array 实现源码](https://github.com/v8/v8/blob/master/src/js/array.js)

v8 在处理 sort 方法时，当目标数组长度小于 10 时，使用插入排序；反之，使用快速排序和插入排序的混合排序。

原因就在于在插入排序的算法中，当待排序元素跟有序元素进行比较时，一旦确定了位置，就不会再跟位置前面的有序元素进行比较，所以就乱序的不彻底。

<!-- more -->

## 实现方式 - Fisher–Yates

算法是由 Ronald Fisher 和 Frank Yates 首次提出的。

```js
function shuffle(a) {
  for (let i = a.length; i; i--) {
    let j = Math.floor(Math.random() * i);
    [a[i - 1], a[j]] = [a[j], a[i - 1]];
  }
  return a;
}
```

[排序算法示例图](https://visualgo.net/en/sorting)
