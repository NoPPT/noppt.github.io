---
title: Leaflet 学习系列（三）标记以及矢量图
date: 2018-06-02 08:34:52
tags:
    - Leaflet
    - JavaScript
categories: GIS
---

[上文][0]介绍了如何使用 Leaflet 加载地图，实际使用时我们不仅仅只加载地图，更多的会在地图上添加一些标记，结合聚合渲染等可视化效果，更清晰的呈现标记点的分布态势（比如添加银行网点的位置信息，附近的商圈信息等等）。也可以添加一些矢量图并设置不同的样式以及属性来区分不同的业务片区，更加直观的服务于业务（比如添加不同物流站点的配送信息以及站点的配送区域等等）。这些功能的实现则需要使用到 Leaflet 提供的 UI Layers 和 Vector Layers。

UI Layers 中提供的类有：

* [Marker][1] 用于在地图上添加可点击和移动的图标
* [Popup][2] 用于在地图的某个点打开弹出窗口
* [Tooltip][3] 用于在地图的某个点显示少量文字

<!-- more -->

Vector Layers 中常用的类有：

* [Polyline][4] 用于在地图上绘制折线
* [Polygon][5] 用于在地图上绘制多边形
* [Circle][6] 用于在地图上绘制圆

接下来我们就使用这些类来实现一些简单的功能。

## Marker

### 初始化方法

```js
L.marker(<LatLng> latlng, <Marker options> options?)

// 更多 options 可选属性，以及默认值
L.marker(latlng, {
    icon: L.Icon.Default, // 默认值为 L.Icon.Default，可使用 L.icon() 自定义图标
    draggable: false, // 设置为 true 可鼠标点击后拖动
    keyboard: true, // 是否可以在点击标记后，按键盘按键制表，即在标记周围显示选中框
    title: '', // 鼠标悬停在标记上是浏览器工具提示的文本
    alt: '', // 图标图像的 alt 属性文本
    zIndexOffset: 0, // 默认情况下根据经纬度自动显示标记的层级，设置的值越高，则显示在比其值低的标记上面
    opacity: 1.0, // 透明度
    riseOnHover: false, // 设置为 true 时在鼠标在移动到标记上时自动显示在最顶层
    riseOffset: 250, // riseOnHover 对应的 z-index 偏移量
    pane: 'markerPane', // 标记将添加到 map 对应的 pane 上
});
```

### 使用

基本使用例子，调用初始化方法，并设置其经纬度，然后添加到地图上。

```js
var marker = L.marker([31.23037, 121.4737]).addTo(mymap);
```

### 自定义标记

如果想要自定义标记显示的样式，可以设置 options 中的 icon 属性为自定义图标 [L.Icon][8]。

```js
var icon = L.icon({
  iconUrl: "./images/apple-touch-icon-next.png",
  iconSize: [60, 60],
  iconAnchor: [30, 30]
});
var customMarker = L.marker([31.23037, 121.4837], {
  icon
}).addTo(mymap);
```

## Path

一个抽象类，虽然我们不会直接使用 [Path][9]，但它包含矢量图（多边形、折线、圆）之间共用的 `options` 和 `constants`。所以我们需要知道这些常用选项有哪些，方便自定义矢量图的样式。

选项 | 类型 | 默认值 | 备注
- | - | - | -
stroke | Boolean | true | 是否绘制路径描边，设置为 false 禁用多边形和圆的边框
color | String | '#3388ff' | 描边颜色
weight | Number | 3 | 描边的宽度，单位像素 px
opacity | Number | 1.0 | 描边的透明度
lineCap | String | 'round'	 | 路径线结束处的样式
lineJoin | String | 'round'	 | 两条路径线相交处的样式

方法 | 备注
- | -
setStyle(<Path options> style) | 更改路径的外观

[更多选项和方法][9]

## Polyline

扩展 Path 类用于绘制线。

### 初始化方法

```js
L.polyline(<LatLng[]> latlngs, <Polyline options> options?)
```

### 常用方法

方法 | 返回值 | 备注
- | - | -
toGeoJSON() | Object | 返回 GeoJSON 类型数据
isEmpty() | Boolean | 返回该折线是否有经纬度信息
addLatLng(<LatLng> latlng) | this | 在折线上增加到该点的路径
getLatLngs() | LatLng[] | 返回折线上点的信息
setLatLngs(<LatLng[]> latlngs) | this | 重置折线所有点
getCenter() | LatLng | 返回该线的中心点

### 使用

```js
var latlngs = [
  [31.23337, 121.4737],
  [31.23437, 121.4747],
  [31.23537, 121.4727]
];
var polyline = L.polyline(latlngs, { color: "red" }).addTo(mymap);

var polylineCenter = polyline.getCenter();
```

## Polygon

扩展 Polyline 类，用于绘制多边形，在创建多边形时传入的点中最后一个点不应该等于第一个点。

### 初始化方法

```js
L.polygon(<LatLng[]> latlngs, <Polyline options> options?)
```

### 使用

```js
var latlngs = [
  [31.23437, 121.4757],
  [31.23537, 121.4757],
  [31.23637, 121.4747],
  [31.23737, 121.4787]
];
var polygon = L.polygon(latlngs, { color: "blue" }).addTo(mymap);
```

## Circle

### 初始化方法

```js
L.circle(<LatLng> latlng, <Circle options> options?)

// options 
{
    radius: Number // 圆的半径，单位米，必须
}
```

### 常用方法

方法 | 返回值 | 备注
- | - | -
setRadius(<Number> radius) | this | 设置圆的半径
getRadius() | Number | 获取圆的半径
getBounds() | LatLngBounds | 返回圆在地图上显示的地理区域

### 使用

```js
var circle = L.circle([31.22537, 121.4727], {
  radius: 400,
  color: "#2af"
}).addTo(mymap);
```

## Popup

用于在地图的某些地方打开弹出窗口。

### 初始化方法

```js
L.popup(<Popup options> options?, <Layer> source?)
```

### 常用方法

方法 | 返回值 | 备注
- | - | -
setLatLng(<LatLng> latlng) | this | 设置popup在某点上打开
setContent(htmlContent) | this | 设置弹框的内容
openOn(<Map> map) | this | 在地图上打开弹框并关闭上一个显示的弹框
openPopup(<LatLng> latlng?) | this | 打开弹框
closePopup() | this | 关闭弹框
bindPopup(content, <Popup options> options?) | this | 绑定弹框到某图层对象
unbindPopup() | this | 解绑
### 使用

```js
var popup = L.popup()
  .setLatLng([31.23037, 121.4637])
  .setContent("<p>Hello world!<br />This is a nice popup.</p>")
  .openOn(mymap);
```

## Tooltip

用于在地图的某个点显示少量文字

### 初始化方法

```js
L.tooltip(<Tooltip options> options?, <Layer> source?)
```

### 使用

```js
marker.bindTooltip("my tooltip text").openTooltip();
```

上述代码添加后的效果如图所示：

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/7.png_blog)

## 进阶

上述只是介绍了这些类的基本使用方法，正如文章开头所述，标记往往需要结合聚合渲染等可视化效果来呈现标记点的分布态势。而矢量图也需要我们手动去设置区域的关键点信息的话又不是很方便，所以希望能够在地图上画出不同的区域。接下来就看下如果实现矢量图的绘制编辑，以及点聚合的效果。

### 绘制编辑

首先我们需要了解几个插件，分别是 [Leaflet.draw][10]、[Leaflet.Editable][11]、[Leaflet.GeometryUtil][12] 和 [Leaflet.Snap][13]。其中 Leaflet.draw、Leaflet.Editable 都提供了矢量图的绘制以及编辑功能，Leaflet.draw 同时提供了一些 UI 控件，而 Leaflet.Editable 只提供了一些 API，使用起来更加灵活。Leaflet.GeometryUtil 提供了一些 API 用于计算几何之间的关系，配合使用 Leaflet.Snap 可以实现在编辑几何图形时捕捉关键点并吸附的功能。

#### 下载源文件并引用 

```js
<script src="/path/to/leaflet.geometryutil.js"></script>
<script src="/path/to/Leaflet.Editable.js"></script>
<script src="/path/to/leaflet.snap.js"></script>
```

#### 绘制

修改 `mymap` 初始化方法，增加 `editable` 属性为 `true`
```js
var mymap = L.map('mapid', {
    editable: true
}).setView([31.23037, 121.47370], 15);
```

然后在控件的点击事件中增加以下代码，根据需求分别调用不同的 API 即可。

```js
// 开始画线
mymap.editTools.startPolyline();
// 开始画多边形
mymap.editTools.startPolygon();
// 开始添加标注
mymap.editTools.startMarker();
// 开始画矩形
mymap.editTools.startRectangle();
// 开始画圆
mymap.editTools.startCircle();
```
#### 编辑

而如果想要在一个已经完成的几何图形启用编辑功能也很简单，获取该对象并调用以下代码就可以了。

```js
polyline.enableEdit();
```

#### 点吸附

在编辑状态时如果想要增加点吸附功能的话，则需要使用 Leaflet.Snap 配合 Leaflet.Editable 的编辑状态事件来实现相关功能。

```js
// 创建 snap 显示的方格，并添加计算的 layer，
var snapMarker = L.marker(map.getCenter(), {
  icon: map.editTools.createVertexIcon({
    className: "leaflet-div-icon leaflet-drawing-icon"
  }),
  opacity: 1,
  zIndexOffset: 1000
});
var snap = new L.Handler.MarkerSnap(map);
snap.watchMarker(snapMarker);
// 如果符合可吸附的规则，则添加辅助标记到地图上，不符合则移除。
snapMarker.on("snap", function(e) {
  snapMarker.addTo(map);
});
snapMarker.on("unsnap", function(e) {
  snapMarker.remove();
});
```
```js
// 在编辑状态更改时修改 snap 参考的 layer,
var followMouse = function (e) {
  snapMarker.setLatLng(e.latlng);
};
mymap.on("editable:vertex:dragstart", function (e) {
  snap.watchMarker(e.vertex);
});
mymap.on("editable:vertex:dragend", function (e) {
  snap.unwatchMarker(e.vertex);
});
mymap.on("editable:drawing:start", function () {
  this.on("mousemove", followMouse);
});
mymap.on("editable:drawing:end", function (e) {
  this.off("mousemove", followMouse);
  snapMarker.remove();
  snap.addGuideLayer(e.layer);
  e.layer.disableEdit();
});
mymap.on("editable:drawing:click", function (e) {
  //当处于新增状态是触发
  var latlng = snapMarker.getLatLng();
  e.latlng.lat = latlng.lat;
  e.latlng.lng = latlng.lng;
});
```

### 点聚合

使用 [Leaflet.markercluster][14] 可以很方便的让我们做出点聚合的效果。

#### 下载文件并引用
```js
<link rel="stylesheet" href="path/to/MarkerCluster.css" />
<link rel="stylesheet" href="path/to/MarkerCluster.Default.css" />
<script src="path/to/leaflet.markercluster.js"></script>
```

#### 添加标记

```js
// 生成点聚合对象
var markers = L.markerClusterGroup();

// addressPoints 数据结构可根据实际情况组织，主要是为了方便生成标记
// 生成 marker 对象并添加到标记群组对象里面
for (var i = 0; i < addressPoints.length; i++) {
  var a = addressPoints[i];
  var title = a[2];
  var marker = L.marker(new L.LatLng(a[0], a[1]), { title: title });
  marker.bindPopup(title);
  markers.addLayer(marker);
}

// markers 添加到地图上
mymap.addLayer(markers);
```

## 实际效果

你可以在这里查看[完整 Demo][7]

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/7.gif_gif)


以上就是关于标记以及矢量图使用的一些总结了，主要介绍了一些类的基础知识和常用方法，以及如何使用三方插件实现一些简单的需求场景，但是我们发现到这里除了使用官方 API 就是使用三方插件，我们自己几乎没有写什么代码，虽然 Leaflet 相关的插件足以满足大部分需求，但是如果只是简单调用 API 的话，那么我们做的东西价值极低，对自身的进步也没有什么提升。想要实现更高级的东西往往需要我们自定义一些插件，接下来就学一下怎么实现自定义插件。


[0]: /2018/05/27/gis-leaflet-tutorials-map-layer/
[1]: https://leafletjs.com/reference-1.0.3.html#marker
[2]: https://leafletjs.com/reference-1.0.3.html#popup
[3]: https://leafletjs.com/reference-1.0.3.html#tooltip
[4]: https://leafletjs.com/reference-1.0.3.html#polyline
[5]: https://leafletjs.com/reference-1.0.3.html#polygon
[6]: https://leafletjs.com/reference-1.0.3.html#circle
[7]: /leaflet.html
[8]: https://leafletjs.com/reference-1.0.3.html#icon
[9]: https://leafletjs.com/reference-1.0.3.html#path
[10]: https://github.com/Leaflet/Leaflet.draw
[11]: https://github.com/Leaflet/Leaflet.Editable
[12]: https://github.com/makinacorpus/Leaflet.GeometryUtil
[13]: https://github.com/makinacorpus/Leaflet.Snap
[14]: https://github.com/Leaflet/Leaflet.markercluster