---
title: Leaflet 学习系列（一）初识
date: 2018-05-27 09:02:20
tags:
    - Leaflet
    - JavaScript
categories: GIS
---

## 前言

最近在学习 [WebGIS][0] 相关框架，现在 WebGIS 平台基本上有三类：一是专业的 GIS 服务商，像全球最成功的 GIS 软件公司 Esri，其提供了齐全 GIS 软件和平台解决方案。二是提供 WebGIS 的各种服务，如百度地图、高德地图等。三是开源的 GIS 软件，其中 WebGIS 服务器比较有代表性的有 [GeoServer][5]，前端开源库有 [Leaflet][3] 和 [Openlayers][6]。由于百度地图提供的服务不满足公司业务需求，所以学习相关的框架。一开始接触的就是 Esri 提供的开源前端库 [ArcGIS API for JavaScript v3.24][1]，在一段时间学习之后感觉没有太多的进步，其学习曲线相当陡峭，而且是基于 dojo 这个学习曲线同样陡峭，古老且文档资料稀缺的前端框架，作为一个互联网行业前端开发，非 GIS 相关专业且不打算在 GIS 行业深入发展，果断就放弃深入学习了。 Leaflet 是[开源][2] GIS 的，可以基于其他开源服务发布的地图服务来打造[全套的开源解决方案][4]，认定方向后就开始 Leaflet 的学习之旅。

<!-- more -->

## Leaflet 是什么

Leaflet 是一个为建设移动设备友好的互动地图，而开发的现代的、开源的 JavaScript 库。它是由 Vladimir Agafonkin 带领一个专业贡献者团队开发，虽然代码仅有 38 KB，但它具有开发人员开发在线地图的大部分功能。
Leaflet 设计坚持简便、高性能和可用性好的思想，在所有主要桌面和移动平台能高效运作，在现代浏览器上会利用 HTML5 和 CSS3 的优势，同时也支持旧的浏览器访问。支持插件扩展，有一个友好、易于使用的 [API 文档][7]和一个简单的、可读的源代码。
Leaflet 强大的[开源库插件][8]涉及到地图应用的各个方面包括地图服务，数据提供，数据格式，地理编码，路线和路线搜索，地图控件和交互等类型的插件共有140多个。这些控件丰富 Leaflet 的功能，同时也可以十分方便的实现自定义的控件具有良好的可扩展性。

## Leaflet 能做什么

上面一通官方介绍之后，对于 Leaflet 了解还是没有什么深刻的印象，那么我们就来看一下它究竟能做些什么，能提供什么样的功能。

### 地图底图

使用 Leaflet 可以加载和切换不同的地图作为底图，Mapbox地图、谷歌地图、天地图、高德地图、百度地图等。

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/1.gif_gif)

[在线演示][9]

### 标记、弹出窗口

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/2.gif_gif)

[在线演示][10]

### 矢量图层

使用 Leaflet 可以很提供了线，多边形，圆形，矩形，以及编辑这些矢量图层，配和使用一些插件可以很方便了对矢量空间数据创建和修改。

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/3.gif_gif)

[在线演示][11]

### 路线规划

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/3.png_blog)

[在线演示][12]

### 地理检索

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/5.gif_gif)

[在线演示][15]

### 热力图

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/4.png_blog)

[在线演示][13]

### Echarts 制图

使用 Leaflet 可以配合一些图表库来展示信息，比如使用百度提供的数据配合 Echarts 制作迁徙图。

![](http://p4wb4s2l1.bkt.clouddn.com/leaflet/4.gif_gif)

[在线演示][14]  [在线演示][16]

## 开始使用

相信通过上面的图文演示之后，大家对 Leaflet 是什么，能做什么会有一定的了解。目前 Leaflet [版本][17]已经更新到 v1.3.1。而版本的更新带来了一些弊端就是一些三方库没有兼容到最新版本，根据我多次尝试之后，最终选择使用 v1.0.3 版本作为接下来的学习使用。接下来就从加载各种地图底图来开始 Leaflet 学习之旅吧~

[0]: https://www.cnblogs.com/naaoveGIS/p/3887141.html
[1]: https://developers.arcgis.com/javascript/3/
[2]: https://github.com/Leaflet/Leaflet
[3]: https://leafletjs.com/
[4]: http://www.cnblogs.com/naaoveGIS/p/4187679.html
[5]: http://geoserver.org/
[6]: https://openlayers.org/
[7]: https://leafletjs.com/reference-1.0.3.html
[8]: https://leafletjs.com/plugins.html
[9]: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
[10]: https://leaflet.github.io/Leaflet.markercluster/example/marker-clustering-realworld.388.html
[11]: https://kklimczak.github.io/Leaflet.Pin/
[12]: http://www.liedman.net/leaflet-routing-machine/
[13]: http://leaflet.github.io/Leaflet.heat/demo/
[14]: http://wandergis.com/leaflet-echarts/
[15]: https://smeijer.github.io/leaflet-geosearch/#openstreetmap
[16]: http://wandergis.com/leaflet-echarts3/examples/index2.html
[17]: https://leafletjs.com/reference-versions.html