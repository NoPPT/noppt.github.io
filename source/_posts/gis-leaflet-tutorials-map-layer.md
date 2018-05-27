---
title: Leaflet 学习系列（二）加载地图
date: 2018-05-27 14:41:10
tags:
    - Leaflet
    - JavaScript
categories: GIS
---

[上文][0]说到使用 Leaflet 可以方便的加载和切换不同的地图作为底图，Mapbox 地图、谷歌地图、天地图、高德地图、百度地图等。那么本篇文章就来介绍下如何快速开始使用 Leaflet 加载和切换不同的地图，以及地图相关的基础知识。

## 准备 HTML 页面

在为地图编写任何代码之前，需要在执行以下准备步骤：

### 创建 HTML 页面

``` html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Document</title>
</head>
<body>

</body>
</html>
```

### 引用 CSS 文件

在 `<head>` 标签里添加以下代码：

``` html
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css"
   integrity="sha512-Rksm5RenBEKSKFjgI3a41vrjkw4EVPlJ3+OiI65vTjIdo9brlAacEuKOiQ5OFh7cOI1bkDwLqdLw3Zg0cRJAAQ=="
   crossorigin=""/>
```

或者[下载源码文件][1]后添加引用

``` html
<link rel="stylesheet" href="/path/to/leaflet.css" />
```

### 添加 JavaScript 文件

加载 CSS 之后添加 JavaScript 文件，记得 JS 文件的引用要放在 CSS 引用下面。

``` html
 <script src="https://unpkg.com/leaflet@1.3.1/dist/leaflet.js"
   integrity="sha512-/Nsx9X4HebavoBvEBuyp3I7od5tA0UzAxs+j83KgC8PU0kgB4XiK4Lfe4y4cgBtaRJQEIFCW+oC506aPT2L1zw=="
   crossorigin=""></script>
```

或者[下载源码文件][1]后添加引用

``` html
<script src="/path/to/leaflet.js"></script>
```

### 添加地图容器

在 `<body>` 标签里面添加 `<div>`，并设置 `id` 属性：

``` html
<div id="mapid"></div>
```

### 设置地图容器样式

可以根据实际情况设置地图的宽高。

``` css
#mapid {
  position: absolute;
  top: 0;
  bottom: 0;
  right: 0;
  left: 0;
}
```

## 设置地图

以上准备工作做好之后，就可以开始初始化地图了。在 `<body>` 下面添加 `<script>`，首先初始化地图并设置地图中心点坐标以及缩放级别。默认情况下地图上的所有鼠标和触摸交互都已启用，并且它具有左上角缩放和右下角属性控件。

``` js
<script>
	var mymap = L.map('mapid').setView([51.505, -0.09], 13);
</script>
```

之后的 JS 代码都要放 `<script>` 标签里。然后我们需要在地图上添加瓦片图层，

``` js
L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.pngaccess_token=pkeyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQrJcFIG214AriISLbB6B5aw', {
	maxZoom: 18,
	attribution: 'Map data &copy; <ahref="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
		'<ahref="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, '+
		'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
	id: 'mapbox.streets'
}).addTo(mymap);
```

## 加载高德地图

## 加载百度地图

## 切换地图

## 相关

[0]: http://0x0803.com/2018/05/27/gis-leaflet-tutorials-map/
[1]: https://github.com/Leaflet/Leaflet/releases
