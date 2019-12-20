---
title: 前端资源懒加载和预加载
date: 2019-2-18 10:07:19
tags:
  - Web
categories: 前端
---

# 懒加载

懒加载也叫延迟加载，指的是在长网页中延迟加载图像，是一种很好优化网页性能的方式。用户滚动到它们之前，可视区域外的图像不会加载。

## 优点

- 能提升用户的体验
- 减少无效资源的加载
- 防止并发加载的资源过多会阻塞 js 的加载

## 原理

首先将页面上的图片的 src 属性设为空字符串，而图片的真实路径则设置在 data-original 属性中，
当页面滚动的时候需要去监听 scroll 事件，在 scroll 事件的回调中，判断我们的懒加载的图片是否进入可视区域,如果图片在可视区内将图片的 src 属性设置为 data-original 的值，这样就可以实现延迟加载。

<!-- more -->

## 实现

```js

<img src="" class="image-item" lazyload="true"  data-original="images/12.png"/>

<script>
var viewHeight =document.documentElement.clientHeight//获取可视区高度
function lazyload(){
var eles=document.querySelectorAll（'img[data-original][lazyload]'）
Array.prototype.forEach.call(eles,function(item,index){
var rect
if(item.dataset.original==="")
   return
rect=item.getBoundingClientRect()// 用于获得页面中某个元素的左，上，右和下分别相对浏览器视窗的位置
if(rect.bottom>=0 && rect.top < viewHeight){
!function(){
  var img=new Image()
  img.src=item.dataset.original
  img.onload=function(){
    item.src=img.src
    }
item.removeAttribute（"data-original"）//移除属性，下次不再遍历
item.removeAttribute（"lazyload"）
   }()
  }
 })
}
lazyload()//刚开始还没滚动屏幕时，要先触发一次函数，初始化首页的页面图片
document.addEventListener（"scroll"，lazyload)
</script>
```

## [jquery_lazyload](https://github.com/tuupola/jquery_lazyload)

---

# 预加载

资源预加载是另一个性能优化技术，我们可以使用该技术来预先告知浏览器某些资源可能在将来会被使用到。预加载简单来说就是将所有所需的资源提前请求加载到本地，这样后面在需要用到时就直接从缓存取资源。

## 优点

- 减少等待的时间

## 实现

- 使用 HTML 标签

`<img src="http://pic26.nipic.com/20121213/6168183 0044449030002.jpg" style="display:none"/>`

- 使用 Image 对象

```js
<script src='./myPreload.js'></script>;
//myPreload.js
var image = new Image();
image.src = "http://pic26.nipic.com/20121213/6168183 004444903000 2.jpg";
```

- 使用 XMLHttpRequest 对象,虽然存在跨域问题，但会精细控制预加载过程
- 使用 PreloadJS 库,PreloadJS 提供了一种预加载内容的一致方式，以便在 HTML 应用程序中使用。
