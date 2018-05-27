---
title: ArcGIS SnappingManager 捕捉管理器
date: 2018-05-23 09:59:57
tags: 
    - ArcGIS
    - JavaScript
    - API
categories: GIS
---

使用 `SnappingManager` 可以用于给 Editor, Measurement Widget,  Draw toolbar 以及 Edit toolbar 等添加捕捉功能。

## 使用场景

当在地图上添加几何时，由于缩放级别，无法令两个几何相邻的边准确的重叠在一起，或者无法准确的在一条边上添加点，此时可以开启捕捉功能，当鼠标位置在响应范围内时，会自动移动到对应的边、顶点或者点。

<!-- more -->

## 使用方法

Method | 作用
--- | ---
new SnappingManager(options?) | 构造函数
destroy() | 销毁对象
getSnappingPoint(screenPoint) | 传入屏幕中的点，如果捕捉到该点会在回掉函数中返回
setLayerInfos(layerInfos) | 鼠标移动时如果同 layerInfos 数组中的 layer 边界、顶点等有重合，将会自动捕捉到重叠的点

### new SnappingManager(options?)

创建一个新的SnappingManager对象。如果要为 Editor, Measurement Widget,  Draw toolbar 以及 Edit toolbar 启用捕捉，请调用地图的 enableSnapping 方法。如果需要修改默认选项，则创建一个新的捕捉管理器对象。

属性 | 值类型 | 备注
--- | --- | ---
alwaysSnap | Boolean | 默认为 false, 此时用户可以通过配合使用快捷键来启用捕捉功能。设置为 true, 捕捉功能可以一直使用
layerInfos | Array<Layer> | 设定可捕捉的 Layer
map | Map | 必要参数，用于设定相关联地图
snapKey | dojo/keys | 当alwaysSnap设置为false时，使用此选项来定义关键用户按下以启用捕捉。默认值是dojo.copyKey。dojo.copyKey是一个虚拟键，映射到Windows上的CTRL和mac上的Command键。
snapPointSymbol | SimpleMarkerSymbol |	定义捕捉位置的符号。默认符号是一个简单的标记符号，具有以下属性：size:15px, color:cyan, style:STYLE_CROSS。
tolerance | Number | 响应范围，在指定像素的半径的圆内的话则为捕捉到。 默认值是15像素。
``` js
# 调用地图的 enableSnapping 方法
var snapManager = map.enableSnapping({
  alwaysSnap: false,
  snapKey: has("mac") ? keys.META : keys.CTRL
});
```

### destroy()

``` js
snappingManager.destroy();
```

### getSnappingPoint(screenPoint)

``` js
var deferred = snappingManager.getSnappingPoint(evt.screenPoint);

deferred.then(function(value){

  if(value !== undefined){

    var snapPoint = value;

  }

},

function(error){

  console.log('failure');

});
```

### setLayerInfos(layerInfos)

属性 | 值类型 | 备注
--- | --- | ---
layer | Layer | 默认选项是将地图中的所有特征和图形图层设置为目标捕捉图层
snapToEdge | Boolean | 默认 true, 对于 polyline or polygon 的边启用捕捉
snapToPoint | Boolean | 默认 true, 对于 point 的点启用捕捉
snapToVertex | Boolean | 默认 true, 对于 polyline or polygon 的顶点启用捕捉

``` json
# layerInfos like:
[
  {
    layer: {
      ...layer
    },
    snapToEdge: true,
    snapToPoint: true,
    snapToVertex: true
  }
];

```

``` js
var layerInfos = [

  {layer:results[0].layer}

];

snappingManager.setLayerInfos(layerInfos);
```

## 使用例子

[官方Demo](https://developers.arcgis.com/javascript/3/jssamples/widget_measurement.html)