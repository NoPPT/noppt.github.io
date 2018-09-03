---
title: Leaflet 学习系列（四）如何写插件理论篇
date: 2018-06-05 21:13:04
tags:
    - Leaflet
    - JavaScript
    - 自定义组件
categories: GIS
---

本篇主要介绍 Leaflet 开发自定义插件的一些理论知识，在日常开发中，仅仅使用 Leaflet 提供的类虽然能满足一些基本需求，但是在一些功能点的实现上需要我们自己写插件来实现功能。如[上文][1]中为了实现点聚合的效果，我们就使用了三方插件，目前 Leaflet [相关的三方插件][2]已经基本满足大部分需求，如果你有一些需求不知道怎么实现，可以先从[这里][2]找一找，如果没有找到的合适的话，然后再自己实现插件。所谓插件即对一些功能的封装，比如之前 TileLayer 我们通过传入不同的参数，来实现加载不同的地图，如果通过扩展 Leaflet 提供的 TileLayer 类，把这些参数定义在子类内部，然后当做一个独立类导出，这样在其他人使用时就无需关心内部逻辑，极大降低了使用难度，同时也避免了大量冗余代码。为 Leaflet 编写插件需要以下基础知识：

- JavaScript
- DOM 操作
- 面向对象编程思想
- 熟悉 Leaflet 原有类

<!--  more -->

首先理论篇和实践篇主要翻译自以下三篇官方教程，当然翻译过程中加入了一些自己的理解，对于英文水平较好且对 Leaflet 已经有一定实践经验的还是建议阅读官方文档和教程。
- [Extending Leaflet: Class Theory][3]
- [Extending Leaflet: Layers][4]
- [Extending Leaflet: Handlers and Controls][5]

## Leaflet 结构

首先来熟悉下 Leaflet 的结构，只有熟悉了 Leaflet 都有哪些类，才能在编写插件时得心应手，知道要扩展那个类，或者哪些类一起使用能实现需求。

![](http://qiniu.0x0803.top/leaflet/8.png_blog)

[在线查看][0]

Leaflet 有以下几种扩展方式：

- 最常用的方式：使用 `L.Class.extend()` 创建 `L.Layer`, `L.Handler` 或者 `L.Control` 的子类实现几种需求
    - 地图移动的同时移动图层
    - 浏览器事件
    - 地图上的控件元素
- 使用 `L.Class.include()` 为 `Class` 添加功能
    - 添加新的 `methods` 和 `options`
    - 修改一些 `methods`
    - 使用 `addInitHook` 执行额外的构造函数代码
- 使用 `L.Class.include()` 更改现有 `Class` 的部分

## L.Class

我们知道在 ECMAScript 只支持`实现继承`，而且其实现继承主要是依靠原型链，其优缺点以及实现的方式就不一一介绍了。Leaflet 中的 `L.Class` 提供了 `extend()`、`include()`、`initialize()` 方法，可以方便实现类的继承。

### L.Class.extend()

使用 `.extend()` 方法创建 Leaflet 中类的子类，方法可传入一个包含键值对的普通对象，对应的 `key` 就是子类的属性名或者方法名，`key` 对应的 `value` 就是其默认值或者方法的实现。

```js
var MyDemoClass = L.Class.extend({
    // A property with initial value = 42
    myDemoProperty: 42,   
    // A method 
    myDemoMethod: function() { return this.myDemoProperty; }
});

var myDemoInstance = new MyDemoClass();
// This will output "42" to the development console
console.log( myDemoInstance.myDemoMethod() );   
```

命名 classes, methods 和 properties 时建议遵循以下建议：

- 函数，方法，属性和工厂命名应该使用小驼峰法 lowerCamelCase
- 类名应该使用大驼峰法 UpperCamelCase
- 私有属性和方法建议使用下划线 `_` 开头。对于 JavaScript 来说所有方法和属性都能被访问，增加下划线前缀只是让我们容易区分属性和方法的状态。

### L.Class.include()

使用 `.include()` 可以为一个已经定义的类重新定义属性、方法或者添加新的属性和方法。

```js
MyDemoClass.include({
    // Adding a new property to the class
    _myPrivateProperty: 78,
    // Redefining a method
    myDemoMethod: function() { return this._myPrivateProperty; }
});

var mySecondDemoInstance = new MyDemoClass();
// This will output "78"
console.log( mySecondDemoInstance.myDemoMethod() );
// However, properties and methods from before still exist
// This will output "42"
console.log( mySecondDemoInstance.myDemoProperty );
```

### L.Class.initialize()

Leaflet 中的类，构造函数的方法命名为 `initialize`。我们可以在构造函数中处理自定义类和原始 `options` 的合并操作以及其他初始化操作。

```js
var MyBoxClass = L.Class.extend({
    options: {
        width: 1,
        height: 1
    },
    initialize: function(name, options) {
        this.name = name;
        L.setOptions(this, options);
    }
});

var instance = new MyBoxClass('Red', {width: 10});

console.log(instance.name); // Outputs "Red"
console.log(instance.options.width); // Outputs "10"
console.log(instance.options.height); // Outputs "1", the default
```

子类会继承父类中的 `options`。

```js
var MyCubeClass = MyBoxClass.extend({
    options: {
        depth: 1
    }
});

var instance = new MyCubeClass('Blue');

console.log(instance.options.width); // Outputs "1", parent class default
console.log(instance.options.height); // Outputs "1", parent class default
console.log(instance.options.depth); // Outputs "1"
```

我们经常会有这种需求，先执行父类的构造函数，然后在执行子类的构造函数。此时可以使用 `L.Class.addInitHook()` 实现。在 `initialize` 函数执行之后会触发钩子执行该方法，此时 `this.options` 已存在且可被访问。

```js
MyBoxClass.addInitHook(function(){
    this._area = this.options.width * this.options.length;
});
```

或者下面这种写法：

```js
MyCubeClass.include({
    _calculateVolume: function(arg1, arg2) {
        this._volume = this.options.width * this.options.length * this.options.depth;
    }
});

MyCubeClass.addInitHook('_calculateVolume', argValue1, argValue2);
```

### 父类方法

使用 `Funcation.call(...)` 调用父类的方法。

```js
L.FeatureGroup = L.LayerGroup.extend({

    addLayer: function (layer) {
        …
        L.LayerGroup.prototype.addLayer.call(this, layer);
    },
    
    removeLayer: function (layer) {
        …
        L.LayerGroup.prototype.removeLayer.call(this, layer);
    },

    …
});
```

调用父类的构造函数 `ParentClass.prototype.initialize.call(this, …)`

### 工厂函数

大多数 Leaflet 中的类都有一个相应的工厂函数，函数名同类名相同，不过命名由大写驼峰改为了小写驼峰。

``` js
function myBoxClass(name, options) {
    return new MyBoxClass(name, options);
}
```

### 命名约定

在为插件命名时，建议遵循以下约定：

- 不在插件中暴露全局变量
- 如果有一个新的类，直接放在 L 命名空间下 (L.MyPlugin)
- 如果继承自一个已经存在的类，将其设置为子属性 (L.TileLayer.BaiduLayer)

[0]: https://leafletjs.com/examples/extending/class-diagram.html
[1]: /2018/06/02/gis-leaflet-ui-vector-layers/
[2]: https://leafletjs.com/plugins.html
[3]: https://leafletjs.com/examples/extending/extending-1-classes.html
[4]: https://leafletjs.com/examples/extending/extending-2-layers.html
[5]: https://leafletjs.com/examples/extending/extending-3-controls.html