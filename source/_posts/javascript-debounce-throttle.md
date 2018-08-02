---
title: JavaScript 函数防抖与函数节流
date: 2018-08-02 09:23:08
tags:
  - JavaScript
categories: JavaScript
---

## 函数防抖

其概念其实是从机械开关和继电器的“去弹跳”（debounce）衍生出来的，基本思路就是把多个信号合并为一个信号。事件内的N个动作会变忽略，只有事件后`由程序触发`的动作有效。如果在间隔内触发的事件会取消上次事件，并等待是否间隔内还有事件触发，如果有则继续取消执行，如果没有则执行本次事件。

### 定时器

每次执行函数前，先清除上次的 setTimeout ，如果在间隔时间内没有再次触发事件，则执行最终的函数

- 用于需要频繁调用的方法时，如input输入框架的格式验证，提交按钮的点击事件
- 在用户不触发事件后才触发动作，并且抑制了本来在事件中要执行的动作。

```js
function debounce(func, wait, immediate) {

    var timeout, result;

    var debounced = function () {
        // 2.修复this指向问题
        var context = this;
        // 3.参数传递问题
        var args = arguments;
        // 1.取消timeout实现防抖
        if (timeout) clearTimeout(timeout);
        // 4.立即执行
        if (immediate) {
            // 如果已经执行过，不再执行
            var callNow = !timeout;
            timeout = setTimeout(function(){
                timeout = null;
            }, wait)
            // 5.返回值问题
            if (callNow) result = func.apply(context, args)
        }
        else {
            timeout = setTimeout(function(){
                func.apply(context, args)
            }, wait);
        }
        return result;
    };
    // 增加重新立即执行
    debounced.cancel = function() {
        clearTimeout(timeout);
        timeout = null;
    };

    return debounced;
}
```

## 节流

如果你持续触发事件，每隔一段时间，执行一次事件。不受上次未执行事件影响，固定事件间隔执行事件。

节流（throttle）的概念可以想象一下水坝，你建了水坝在河道中，不能让水流动不了，你只能让水流慢些。换言之，你不能让用户的方法都不执行。如果这样干，就是debounce了。为了让用户的方法在某个时间段内只执行一次，我们需要保存上次执行的时间点与定时器。

- 用于更频繁触发的事件，如resize, touchmove, mousemove, scroll。
- 比较适合应用于动画相关的场景。

关于节流的实现，有两种主流的实现方式，一种是使用时间戳，一种是设置定时器。

### 1. 时间戳

```js
function throttle(func, wait) {
    var context, args;
    var previous = 0;

    return function() {
        var now = +new Date();
        context = this;
        args = arguments;
        if (now - previous > wait) {
            func.apply(context, args);
            previous = now;
        }
    }
}
```

### 2. 定时器

```js
function throttle(func, wait) {
    var timeout;
    var previous = 0;

    return function() {
        context = this;
        args = arguments;
        if (!timeout) {
            timeout = setTimeout(function(){
                timeout = null;
                func.apply(context, args)
            }, wait)
        }

    }
}
```

- 第一种事件会立刻执行，第二种事件会在 n 秒后第一次执行
- 第一种事件停止触发后没有办法再执行事件，第二种事件停止触发后依然会再执行一次事件

### 3. 优化

```js
function throttle(func, wait, options) {
    var timeout, context, args, result;
    var previous = 0;
    if (!options) options = {};

    var later = function() {
        previous = options.leading === false ? 0 : new Date().getTime();
        timeout = null;
        func.apply(context, args);
        if (!timeout) context = args = null;
    };

    var throttled = function() {
        var now = new Date().getTime();
        if (!previous && options.leading === false) previous = now;
        var remaining = wait - (now - previous);
        context = this;
        args = arguments;
        if (remaining <= 0 || remaining > wait) {
            if (timeout) {
                clearTimeout(timeout);
                timeout = null;
            }
            previous = now;
            func.apply(context, args);
            if (!timeout) context = args = null;
        } else if (!timeout && options.trailing !== false) {
            timeout = setTimeout(later, remaining);
        }
    };

    throttled.cancel = function() {
        clearTimeout(timeout);
        previous = 0;
        timeout = null;
    };

    return throttled;
}
```