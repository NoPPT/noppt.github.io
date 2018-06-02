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

在为地图编写任何代码之前，需要以下准备步骤：

<!-- more -->

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

或者[下载源码文件][1]后添加引用，如果你使用 `npm` 包管理可以[参考这里][2]

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

或者引用源文件

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

以上准备工作做好之后，就可以开始初始化地图了。在 `<body>` 下面添加 `<script>`，首先初始化地图并设置地图中心点坐标以及缩放级别。默认情况下地图上的所有鼠标和触摸交互都已启用，并且它具有左上角缩放和右下角地图归属控件。

``` js
<script>
	var mymap = L.map('mapid').setView([51.505, -0.09], 13);
</script>
```

之后的 JS 代码都要放 `<script>` 标签里。然后我们需要在地图上添加瓦片图层，

``` js
  L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
    maxZoom: 18,
    attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
      '<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
      'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
    id: 'mapbox.streets'
  }).addTo(mymap);
```
然后在浏览器中打开 HTML 页面就可以看到我们已经将地图加载出来了。

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/6.png_blog)

## 常用属性、事件及方法

可以看到上面代码 `L.map('mapid')` 生成 `map` 对象，然后使用 `setView` 方法设置位置以及缩放级别，一般调用地图的方法时也会返回地图对象，这样可以方便的进行链式方法调用。除了上面两个方法外还有以下常用[属性、事件及方法][3]

### 属性

``` js
// 初始化方法
L.map(<String> id, <Map options> options?)

// 以下为常用属性及其默认值
L.map('mapid', {
  attributionControl: true, // 设置为 false 隐藏地图归属信息控件
  zoomControl: true, // 设置为 false 隐藏地图缩放控件
  doubleClickZoom: true, // 设置为 false 禁止双击缩放
  dragging: true, // 设置为 false 禁止鼠标拖动地图
  center: LatLng, // 设置地图中心点位置信息
  zoom: Number // 设置地图当前缩放级别
  minZoom: Number // 设置地图最小缩放级别
  maxZoom: Number // 设置地图最大缩放级别
  scrollWheelZoom: true // 设置为 false 禁止使用鼠标滑轮缩放地图
})
```

[更多属性][4]

### 事件

事件名 | 类型 | 触发时机
--- | --- | ---
layeradd | LayerEvent | 当一个新的图层添加到地图上时
layerremove | LayerEvent | 当一个图层从地图上移除时
load | Event | 当地图初始化完成时
click | MouseEvent | 鼠标点击地图时
mousemove | MouseEvent | 鼠标在地图上移动时
contextmenu | MouseEvent | 鼠标在地图上点击右键时，可以监听此事件覆盖默认右键菜单（手机上长按屏幕）

``` js
// 使用方法
mymap.on('click', function (e) {
  console.log(e);
})
```

[更多事件][5]

### 方法

方法 | 返回值 | 备注
--- | --- | ---
addControl(<Control> control) | this | 在地图上添加控件
removeControl(<Control> control) | this | 移除地图上的控件
addLayer(<Layer> layer) | this | 在地图上添加图层
removeLayer(<Layer> layer) | this | 移除地图上的图层
openPopup(<Popup> popup) | this | 打开 popup，并关闭其他 popup
closePopup(<Popup> popup?) | this | 关闭 popup
setView(<LatLng> center, <Number> zoom, <Zoom/pan options> options?) | this | 设置地图属性
setZoom(<Number> zoom, <Zoom/pan options> options) | this | 设置地图缩放级别
locate(<Locate options> options?) | this | 使用 Geolocation API 获取用户位置信息，成功时触发“locationfound“事件，失败触发“locationerror”事件。在现代浏览器（Chrome 50及更新版本）如果网站不是 `https` 则会获取失败。返回坐标为 `WGS84`，可以使用 [coordtransform][17] 转换为需要的坐标。
remove() | this | 销毁地图并移除所有已监听的事件响应

``` js
  // 上面的加载图层也可以用这种写法，效果一样。
  mymap.addLayer(
    L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
    maxZoom: 18,
    attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
      '<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
      'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
    id: 'mapbox.streets'
  }));
```
[更多方法][6]

## 加载其他地图服务

虽然 Leaflet 默认教程中使用的都是 OpenStreetMap，但是在国内使用的话，高德地图、百度地图更加实用，使用 Leaflet 可以很简单的加载高德地图，而[百度地图的瓦片规则和普通的互联网地图的瓦片规则][9]（[相关1][10]，[相关2][11]）不那么一样，需要进行转换后才能正常使用。不过 Leaflet 提供了 [CRS][7] 类定义坐标参考系统，用于将地理点投影到像素（屏幕）坐标（以及用于WMS服务的其他单位的坐标）。配合使用 [Proj4Leaflet][8] 插件可以方便实现自定义 CRS。然后使用 [TileLayer][12] 加载地图图层。

### 初始化方法

``` js
L.tilelayer(<String> urlTemplate, <TileLayer options> options?)

// 用法事例，常用属性及默认值
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png?{foo}', {
  minZoom: 0, // 最小缩放级别
  maxZoom: 18, // 最小缩放级别
  subdomains: 'abc', // 子域名，对应 urlTemplate 链接中的参数 {s}
  errorTileUrl: '', // 加载失败时的图片地址
  detectRetina: false， // 用户在视网膜显示器上可以设置为true，来利用高分辨率。
}).addTo(mymap);
```

### 加载高德地图

Leaflet Map 属性 `crs` 默认值为 `L.CRS.EPSG3857`，球形墨卡托投影。因此只要我们知道高德地图的瓦片图地址，无需对高德地图瓦片做任何处理，就能够加载出正确的地图。

``` js
  mymap.addLayer(L.tileLayer('http://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}', {
    subdomains: ['1', '2', '3', '4'],
    minZoom: 1,
    maxZoom: 19
  }));
```

类似的谷歌地图或者其他同类瓦片坐标地图我们只要知道瓦片地址链接，然后替换 `urlTemplate` 参数和 `subdomains` 属性就能加载不同的地图了。

地图 | 瓦片地址 | 子域名 | 层级
--- | --- | --- | ---
高德地图 | http://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z} | ['1', '2', '3', '4'] | 1~19
高德地图卫星 | http://webst0{s}.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z} | ['1', '2', '3', '4'] | 1~19
高德地图标注 | http://webst0{s}.is.autonavi.com/appmaptile?style=8&x={x}&y={y}&z={z} | ['1', '2', '3', '4'] | 1~19
谷歌地图 | http://www.google.cn/maps/vt?lyrs=m@189&gl=cn&x={x}&y={y}&z={z} | [] | 0~21
谷歌地图卫星 | http://www.google.cn/maps/vt?lyrs=s@189&gl=cn&x={x}&y={y}&z={z} | [] | 0~21

如果要用到以上所有的地图，可以使用 [Leaflet.ChineseTmsProviders][13] 插件，其对这些常用的地图做了简单封装，方便在地图上添加。

### 加载百度地图

上面说到百度地图需要进行转换后才能正常使用，其转换方法也有已知解决方案，如下步骤：

#### 添加 Proj4Leaflet

从这里[下载源码][8]，然后添加引用

``` html
  <script src="/path/to/proj4-compressed.js"></script>
  <script src="/path/to/proj4leaflet.js"></script>
```

#### 自定义 CRS

初始化地图前，[自定义 CRS][15] 并[纠偏][14]

``` js
// 初始化百度地图瓦片图层，投影坐标转换以纠偏地图显示问题
const baiduCrs = new L.Proj.CRS(
  "EPSG:900913",
  "+proj=merc +a=6378206 +b=6356584.314245179 +lat_ts=0.0 +lon_0=0.0 +x_0=0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs",
  {
    resolutions: (function() {
      level = 19;
      var res = [];
      res[0] = Math.pow(2, 18);
      for (var i = 1; i < level; i++) {
        res[i] = Math.pow(2, 18 - i);
      }
      return res;
    })(),
    origin: [0, 0],
    bounds: L.bounds([20037508.342789244, 0], [0, 20037508.342789244])
  }
);

var mymap = L.map("mapid", {
  crs: baiduCrs,
});
```

#### 百度地图图层

``` js
// TileLayer 扩展
L.TileLayer.BaiduLayer = L.TileLayer.extend({
  options: {
    minZoom: 3,
    maxZoom: 18,
    // subdomains: ["online1", "online2", "online3"],
    // attribution:
    //   '&copy; <a href="http://www.ksudi.com">Ksudi</a> contributors',
    style: "normal",
    tms: true
  },
  _urls: {
    normal:
      "https://ss0.bdstatic.com/8bo_dTSlRsgBo1vgoIiO_jowehsv/tile/?qt=tile&x={x}&y={y}&z={z}&styles=pl&scaler=2&udt=20170803",
    weixing:
      "https://ss0.bdstatic.com/5bwHcj7lABFT8t_jkk_Z1zRvfdw6buu/it/u=x={x};y={y};z={z};v=009;type=sate&fm=46&udt=20170803"
  },
  _weixing_label_url:
    "https://ss0.bdstatic.com/8bo_dTSlRMgBo1vgoIiO_jowehsv/tile/?qt=tile&x={x}&y={y}&z={z}&styles=sl&udt=20141015",
  /**
   * url:
   * style:
   */
  initialize: function(options) {
    let that = this;
    let url;
    if (options.url) {
      url = options.url;
    } else if (options.style) {
      url = that._urls[options.style];
    }

    url || (url = that._urls["normal"]);
    L.TileLayer.prototype.initialize.call(this, url, options);

    if ("weixing" == options.style) {
      that.labelLayer = new L.TileLayer.BaiduLayer({
        url: that._weixing_label_url
      });

      that.on("add", function() {
        that.labelLayer.addTo(that._map);
      });
    }
  },

  getTileUrl: function(t) {
    return L.TileLayer.prototype.getTileUrl.call(this, t);
  }
});

L.tileLayer.baiduLayer = function(options) {
  return new L.TileLayer.BaiduLayer(options);
};
```

#### 添加到地图

``` js
// 使用
const baiduLayer = L.tileLayer.baiduLayer({
  style: "normal"
});
baiduLayer.addTo(mymap);
```

## 切换地图

以上我们就把地图的常用方法，以及常用地图的加载介绍完毕。我们可能会有在使用时加载多个地图图层，然后根据情况切换图层的需求。我们可以借助于 [Control.Layers][16] 来实现。

初始化 | 备注
--- | ---
L.control.layers(<Object> baselayers?, <Object> overlays?, <Control.Layers options> options?) | 使用给定的层创建一个属性控件。基层将使用单选按钮来切换，而覆盖将用复选框来切换。请注意，所有的基层都应该在基层对象中传递，但是在地图实例化过程中，应该只在映射中添加一个。

```
var baseLayers = {
    "Mapbox": mapbox,
    "OpenStreetMap": osm
};
var overlays = {
    "Marker": marker,
    "Roads": roadsLayer
};
L.control.layers(baseLayers, overlays).addTo(map);
```

实现效果如下:

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/6.gif_gif)



[0]: http://0x0803.com/2018/05/27/gis-leaflet-tutorials-map/
[1]: https://github.com/Leaflet/Leaflet/releases
[2]: https://leafletjs.com/download.html
[3]: https://leafletjs.com/reference-1.0.3.html#map-example
[4]: https://leafletjs.com/reference-1.0.3.html#map-option
[5]: https://leafletjs.com/reference-1.0.3.html#map-event
[6]: https://leafletjs.com/reference-1.0.3.html#map-methods-for-modifying-map-state
[7]: https://leafletjs.com/reference-1.0.3.html#crs
[8]: https://github.com/kartena/Proj4Leaflet
[9]: http://www.cnblogs.com/cglNet/archive/2013/11/26/3443637.html
[10]: http://cntchen.github.io/2016/05/09/国内主要地图瓦片坐标系定义及计算原理/
[11]: http://www.cnblogs.com/jz1108/archive/2011/07/02/2095376.html
[12]: https://leafletjs.com/reference-1.0.3.html#tilelayer
[13]: https://github.com/htoooth/Leaflet.ChineseTmsProviders
[14]: https://blog.csdn.net/u012087400/article/details/53744756?utm_source=itdadao&utm_medium=referral
[15]: https://blog.csdn.net/u012087400/article/details/52847614?locationNum=13&fps=1
[16]: https://leafletjs.com/reference-1.0.3.html#control-layers
[17]: https://github.com/wandergis/coordtransform