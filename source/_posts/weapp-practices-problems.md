---
title: 微信小程序实践问题总结
date: 2018-05-09 21:03:06
tags:
    - 微信小程序
    - 问题总结
categories: 微信小程序
---

### 如何使组件高度为满屏，并非自动收缩高度

```css
# 自动收缩高度
.container {
  height: 100%;
  display: flex;
} 

# 满屏
.container {
  height: 100vh;
  display: flex;
} 
```

<!-- more -->

### `position` 各值的区别

- fixed（固定定位）：生成绝对定位的元素，相对于当前 window 进行定位。
- absolute（绝对定位）：生成绝对定位的元素，相对于 static 定位以外的第一个父元素进行定位。
- static（静态定位）：默认值。没有定位，元素出现在正常的流中。
- relative（相对定位）：生成相对定位的元素，通过top,bottom,left,right的设置相对于其正常（原先本身）位置进行定位。可通过z-index进行层次分级。

- 添加在 `scroll-view`, `swiper` 内部的组件如果设置 `css` 属性 `position: fixed` 后在 iOS 真机上表现形式同 `position: absolute`

### 添加 `overflow` 属性后，iOS 真机 `z-index` 失效

```
.home-search-content {
  display: flex;
  margin-top: 300rpx;
  width: 100%;
  flex-direction: column;
  z-index: 999;
  /* overflow: hidden; */
}
```

### 重复添加同一动画效果无效

原因是每次 export 方法调用后会清掉之前的动画效果。加粗的注意事项当时竟然看到后没有思考可能出现的情况。[wx.createAnimation(OBJECT)](https://mp.weixin.qq.com/debug/wxadoc/dev/api/api-animation.html#wxcreateanimationobject)

###  `scroll-view` 高度自动填充剩余高度

设置 `scroll-view` 高度自动填充剩余高度，且纵向滑动。（此种方法在性能较差机器上，且scrollview内部子组件会经常变化时可能导致一些渲染问题）

```
view height: 100%; overflow-y: auto
---------------------
topbar height: 98rpx;
---

scroll-view height: 100%;

---
tabbar height: 98rpx;
---------------------

设置 scroll-view  height: 100%,
设置其父容器  height: 100%; overflow-y: auto; 
```

设置 `scroll-view` 高度为 `100vh`，然后设置 `topbar` 和 `tabbar` 为绝对定位。然后设置 `scroll-view` 内部组件的第一个和最后一个，分别设置 `margin-top: @topbar-height` 和 `margin-bottom: @tabbar-height`（在设置高度为100vh后，如果 topbar 和 tabbar 的定位不是绝对定位的话，scroll-view 不能占满整个屏幕，此时在当前 scroll-view 弹出一个定位信息为 fixed 的 modal 时，可能导致 scroll-view 的滑动出现一定的问题，如不能滑动到最顶部。）



持续更新...