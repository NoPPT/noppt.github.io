---
title: 微信小程序自定义组件实践
date: 2018-04-01 18:01:06
tags:
    - 微信小程序
    - 自定义组件
    - 实践
categories: 微信小程序
---
>从小程序基础库版本 1.6.3 开始，小程序支持简洁的组件化编程。所有自定义组件相关特性都需要基础库版本 1.6.3 或更高。
>开发者可以将页面内的功能模块抽象成自定义组件，以便在不同的页面中重复使用；也可以将复杂的页面拆分成多个低耦合的模块，有助于代码维护。自定义组件在使用时与基础组件非常相似。

作为一个小程序初学者，一开始看到[自定义组件][0]时，虽然文档已经写的很详细了，整体上都能看的懂，但看完之后感觉缺少实践理解不是很透彻，好在后来项目开发中需要自定义 PickerView，实践过后感觉熟练了不少，此时把开发过程中的一些实践配合官方文档总结下来。

<!--more-->

## 创建自定义组件

创建一个自定义组件十分简单，只需要在项目中点击`右键=>新建=>Component`，输入组件名，就会生成相应的 `json`，`wxml`，`wxss`，`js` 文件（为了方便管理，建议把自定义组件相关代码文件放在同一文件夹下面）。我们可以看到在 `json` 文件中已经将 `component` 属性设置为 `true`，代表这组文件为自定义组件。

``` index.json
{
  "component": true,
  "usingComponents": {}
}
```
同时，还要在 `wxml` 文件中编写组件模版，在 `wxss` 文件中加入组件样式，在 `js` 文件中写对应的组件逻辑。

接下来，就要考虑下组件需要实现哪些功能。这里要实现的是一个 `PickerView`。设计如下：
{% gp 4-3 %}
![](http://p4wb4s2l1.bkt.clouddn.com/image/blog/2/1.png-blog)
![](http://p4wb4s2l1.bkt.clouddn.com/image/blog/2/2.png-blog)
![](http://p4wb4s2l1.bkt.clouddn.com/image/blog/2/3.png-blog)
![](http://p4wb4s2l1.bkt.clouddn.com/image/blog/2/4.png-blog)
{% endgp %}

分析项目的实际需要，首先要有一套基本的样式，但是有些地方的高度不同，我们的项目只需要显示一列数据进行选择，暂时不需要级联的效果。需要单选和多选的功能，而且不同地方使用时对应的 `picker-item`（后面简称`行`） 显示的结构会有所不同。

总结下我们需要实现以下功能：
- 默认样式和结构
- 打开和关闭
- 自定义样式
- 单选和多选
- 自动滑动到选中行
- 自定义行结构

接下来就一一实现上面的需求。

## 需求实现

这里就把实现时的大概步骤和实现给记录下，所有的代码在这里可以[查看和下载][6]。

### 默认样式和结构

按照以下目录创建文件，把所有相关的文件都放在同一文件夹下，方便统一管理，然后在文件夹下创建两个自定义组件和一个模板。`index` 提供整个 `picker-view` 相关的属性和事件。`item` 作为 `picker-item` 的容器，通过 `<slot>` 节点承载组件引用时的默认模板和自定义模板子节点，方便之后自定义行模板。`default-item` 就是 `picker-view` 默认的行模板了。

```
├── components
│   └── picker
│       ├── default-item.wxml
│       ├── default-item.wxss
│       ├── index.js
│       ├── index.json
│       ├── index.wxml
│       ├── index.wxss
│       ├── item.js
│       ├── item.json
│       ├── item.wxml
│       └── item.wxss
```

### 打开和关闭

简单点实现就是通过 `wx:if="{{show}}"`来判断是否显示组件，不过效果太生硬，还是要添加点动画效果，这里使用的是微信提供的 API：[wx.createAnimation][1]。在 `index.js` 中添加组件属性 `show`，然后监听 `show` 值的变化，判断是打开还是关闭状态，执行不同的动画效果。这里有一点需要注意的是每次都需要重新使用 `wx.createAnimation` 生成动画实例，因为 `export` 方法每次调用后会清掉之前的动画操作。除设置 `show` 属性的值外，还可以在引用组件的地方通过 `selectComponent("#custom-id")` 方法获取组件实例节点，执行 `show()` 和 `hide()`方法来控制组件的显示状态。

```js
// properties
show: {
  type: Boolean,
  value: false,
  observer: '_onChangeShow'
},

// methods
_onChangeShow: function (newVal, oldVal) {
  if (newVal !== oldVal) {
    if (newVal) {
      this.show();
    } else {
      this.hide();
    }
  }
},

_initShowAnimate: function () {
  const that = this;

  const showAnimate = wx.createAnimation({
    duration: that.animateTime,
    timingFunction: 'ease'
  });
  showAnimate.bottom('0rpx').opacity(1).step();

  const bgShowAnimate = wx.createAnimation({
    duration: that.animateTime,
    timingFunction: 'ease'
  });
  bgShowAnimate.backgroundColor('rgba(0, 0, 0, 0.7)').step();

  return { showAnimate, bgShowAnimate };
},

_initHideAnimate: function () {
  const that = this;

  const hideAnimate = wx.createAnimation({
    duration: that.animateTime,
    timingFunction: 'ease'
  })
  hideAnimate.bottom('-586rpx').opacity(0).step();

  const bgHideAnimate = wx.createAnimation({
    duration: that.animateTime,
    timingFunction: 'ease'
  })
  bgHideAnimate.backgroundColor('rgba(0, 0, 0, 0)').step();

  return { hideAnimate, bgHideAnimate };
},

show: function () {
  const { showAnimate, bgShowAnimate } = this._initShowAnimate();
  this.setData({
    animation: showAnimate.export(),
    bgAnimation: bgShowAnimate.export(),
  });
},

hide: function () {
  if (!this.data.show) {
    return;
  }
  const { hideAnimate, bgHideAnimate } = this._initHideAnimate();
  this.setData({
    animation: hideAnimate.export(),
    bgAnimation: bgHideAnimate.export(),
  });

  const that = this;
  setTimeout(() => {
    that.triggerEvent("hide", {}, {})
    that.setData({
      show: false
    });
  }, that.animateTime);
},
```

使用已注册的自定义组件前，首先要在页面的 `json` 文件中进行引用声明。此时需要提供每个自定义组件的标签名和对应的自定义组件文件路径。这样，在页面的 `wxml` 中就可以像使用基础组件一样使用自定义组件。节点名即自定义组件的标签名，节点属性即传递给组件的属性值。自定义组件的 `wxml` 节点结构在与数据结合之后，将被插入到引用位置内。

```json
// index.json
{
  "component": true,
  "usingComponents": {
    "item": "./item"
  }
}
```

```html
<!-- item.wxml -->
<view id='into-{{key}}' class="item" bindtap='_onTapPickerItem'>
  <slot></slot>
</view>
```

`picker-item` 作为行模板的容器，绑定点击事件，这样就不用关心行结构，只需要处理好 `picker-item` 在点击时同 `picker-view` 之间的交互逻辑就好了。同样的，我们提供一个默认行模板，用于满足基本的使用需求。可以根据项目中的需求来决定默认的行模板。

```html
<!-- default-item.wxml -->
<template name='default-item'>
  <view class='default-item-container' style="background-color: {{choose ? '#2089ff' : '#fff'}};">
    <text class='defaulte-item-text' style="color: {{choose ? '#fff' : '#333'}}">{{ title }}</text>
  </view>
</template>
```
这样，我们的 `picker-view` 的就如下所示：使用 `scroll-view` 组件作为承载 `picker-item` 的容器。
```html
<!-- index.wxml -->
<view wx:if="{{show}}" class="action-container" animation="{{bgAnimation}}">
  <view class="list-container" animation="{{animation}}">
    <view class="tool-bar">
      <text class='cancel-text' bindtap='onTapClear'>取消</text>
      <text wx:if="{{multiple}}" class='all-text' bindtap='onTapAll'>全选</text>
      <text class='ok-text all-text' bindtap='onTapOk'>确认</text>
    </view>
    <scroll-view class='scroll' scroll-y scroll-into-view="{{defaultView}}">
      <item id="{{'into-' + index}}" wx:for="{{items}}" wx:key="{{item.name}}" key="{{index}}" bindselect="onTapPickerItem">
        <template is="default-item" data="{{ choose: item.choose, title: item.name}}" />
      </item>
    </scroll-view>
  </view>
</view>
```
```css
/* index.wxss */
.action-container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: transparent;
  z-index: 1000;
}

.list-container {
  position: absolute;
  bottom: -586rpx;
  width: 100vw;
  height: 586rpx;
  background-color: #fff;
  display: flex;
  flex-direction: column;
  opacity: 0;
  z-index: 1010;
}

.scroll {
  flex: 1;
  height: 496rpx;
  width: 100vw;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}
```

### 自定义样式

在微信提供的文档[组件模版和样式][2]中，提到可以在 `Component` 中用 `externalClasses` 定义段定义若干个外部样式类。这个特性从小程序基础库版本 `1.9.90` 开始支持。这里的话考虑到组件要支持低版本，而且 `externalClasses` 使用起来不够灵活。所以这里还是通过属性来实现自定义高度的需求。实践中发现的一个问题是，设置 `scroll-view` 的高度 `height: 100%` 虽然也能实现自动填充高度，但是在部分机型上展示有问题。所以还是监听高度属性的变化，然后计算 `scroll-view` 的高度，并更新。

```js
// properties
height: {
  type: String,
  value: '586rpx',
  observer: '_onChangeHeight'
}

//methods
_onChangeHeight: function (newVal, oldVal) {
  if (newVal && newVal !== oldVal) {
    const height = (newVal.split('rpx')[0] - 90) + 'rpx';
    this.setData({
      containerHeight: height
    })
  }
},

//wxml
<scroll-view class='scroll' style="height: {{containerHeight}};" scroll-y>
</scroll-view>
```

### 单选和多选

我们已经监听的 `picker-item` 的点击事件 `bindselect="onTapPickerItem"`，只需要在每次点击时更新下当前行数据的选中状态。这里在实现时使用的方法是在每行的数据结构中增加 `choose` 属性用于存储行的选中状态。这样只需要处理好每次选中时数据的更新就好了，然后重新渲染组件。在取消的时候恢复原始的数据状态，点击确认时把当前的数据传递到使用 `picker-view` 的页面。

```js
// index.js
onTapPickerItem: function (res) {
  this.handleTapItem(res.detail.key);
},

handleTapItem: function (index) {
  if (index == undefined) {
    return;
  }
  const that = this;
  const newDatas = this._changeDataChoose(this.selIndex, index);
  this.setData({
    items: newDatas
  }, function () {
    if (that.data.custom) {
      that.changeSelectItem();
    }
  })
},

onTapOk: function () {
  this.changeSelectItem('confirm');
  this.hide();
},

changeSelectItem: function (type = 'change') {
  let items = this.data.items;
  let current = this.selIndex;
  if (type === 'cancel') {
    items = this.defaultItems;
    current = this.defaultSelect;
  } else if (type === 'confirm') {
    this.defaultItems = undefined;
    this.defaultSelect = undefined;
  }

  this.triggerEvent("change", {
    current,
    items,
    type
  }, {})
},

_changeDataChoose: function (lastIndex, currentIndex) {
  let lastDatas = this.data.items;

  if (this.data.multiple) {
    if (typeof currentIndex != 'object' && Number(currentIndex) != NaN) {
      if (lastDatas[currentIndex].choose) {
        lastDatas[currentIndex].choose = false;
        const index = this.selIndex.indexOf(currentIndex)
        this.selIndex.splice(index, 1);
      } else {
        lastDatas[currentIndex].choose = true;
        this.selIndex = [...this.selIndex, currentIndex];
      }
    } else {
      this.selIndex = lastIndex;
      lastIndex.forEach((value, index) => {
        lastDatas[value].choose = true;
      });
    }
  } else {
    if (lastIndex >= 0 && lastIndex < lastDatas.length) {
      lastDatas[lastIndex].choose = false;
    }
    if (currentIndex >= 0 && currentIndex < lastDatas.length) {
      lastDatas[currentIndex].choose = true;
    }
    this.selIndex = currentIndex;
  }
  return lastDatas;
}
```

### 自动滑动到选中行

主要是使用 `scroll-view` 提供的属性 `scroll-into-view="{{defaultView}}"`，在每次打开 `picker-view` 时设置 `defaultView` 的值为当前选中的行，需要注意的一点是 `scroll-into-view` 对应的值值应为某子元素 id，id 不能以数字开头。

```
show: function () {
  const { showAnimate, bgShowAnimate } = this._initShowAnimate();
  const defaultView = 'into-' + Number(this.data.current);
  this.setData({
    animation: showAnimate.export(),
    bgAnimation: bgShowAnimate.export(),
    defaultView: defaultView
  });
},
```

### 自定义行模板

自定义行模板时主要需要处理的是，如何把选中的状态更新逻辑给抽取出来，这样使用时就只需要提供一套自定义的模板就行了。[组件间关系][4] 这一节提到：自定义组件有相互间的关系，相互间的通信往往比较复杂。此时在组件定义时加入 `relations` 定义段，可以解决这样的问题。在 `index` 和 `item` 两个组件定义中都加入 `relations`定义，`index` 作为父组件，在有 `linked` 子组建时更新下属性 `custom` 的值，作为是否使用自定义的行结构的标识。 `item` 作为子组件，在 `linked` 时保存父组件的引用，这样可以在有点击事件时调用对应的父组件里的方法。

```js
// index.js
relations: {
  './item': {
    type: 'child', // 关联的目标节点应为子节点
    linked: function (target) {
      // 每次有item被插入时执行，target是该节点实例对象，触发在该节点attached生命周期之后
      if (!this.data.custom) {
        this.setData({
          custom: true
        })
      }
    },
    linkChanged: function (target) {
      // 每次有custom-li被移动后执行，target是该节点实例对象，触发在该节点moved生命周期之后
    },
    unlinked: function (target) {
      // 每次有custom-li被移除时执行，target是该节点实例对象，触发在该节点detached生命周期之后
    }
  }
},
```

```js
// item.js
relations: {
  './index': {
    type: 'parent', // 关联的目标节点应为父节点
    linked: function (target) {
      // 每次被插入到custom-ul时执行，target是custom-ul节点实例对象，触发在attached生命周期之后
      this.parent = target;
    },
    linkChanged: function (target) {
      // 每次被移动后执行，target是custom-ul节点实例对象，触发在moved生命周期之后
    },
    unlinked: function (target) {
      // 每次被移除时执行，target是custom-ul节点实例对象，触发在detached生命周期之后
    }
  }
},

// methods
_onTapPickerItem: function (target) {
  if (this.parent) {
    this.parent.handleTapItem && this.parent.handleTapItem(this.data.key);
  } else {
    this.triggerEvent('select', {
      key: this.data.key
    }, {});
  }
}
```
修改下 `index.wxml` 的结构。

```html
<!-- index.wxml -->
<scroll-view wx:if="{{!custom}}" class='scroll' style="height: {{containerHeight}};" scroll-y scroll-into-view="{{defaultView}}">
  <item id="{{'into-' + index}}" wx:for="{{items}}" wx:key="{{item.name}}" key="{{index}}" bindselect="onTapPickerItem">
    <template is="default-item" data="{{ choose: item.choose, title: item.name}}" />
  </item>
</scroll-view>
<scroll-view wx:if="{{custom}}" class='scroll' style="height: {{containerHeight}};" scroll-y scroll-into-view="{{defaultView}}">
  <slot></slot>
</scroll-view>
```

## 使用自定义组件

在页面中使用自定义组件，首先在 `.json` 添加文件中引用：
```json
{
  "usingComponents": {
    "picker": "/components/picker/index",
    // 如果需要自定义行结构就添加 item
    "picker-item": "/components/picker/item"
  }
}
```

``` js
Page({
  data: {
    visible: false,
    items: [
      { name: '1' },
      { name: '2' },
      { name: '3' },
      { name: '4' },
      { name: '5' },
      { name: '6' },
      { name: '7' },
      { name: '8' },
    ],
    current: []
  },

  onTapShowActionSheet: function () {
    this.setData({
      visible: true
    })
  },

  onChangeSelect: function (target) {
    this.setData({
      current: target.detail.current,
      items: target.detail.items
    })
  }
})
```

```html
<!--index.wxml-->
<view class="container">
  <button bindtap='onTapShowActionSheet'>显示ActionSheet</button>
  <picker show="{{visible}}" bindchange="onChangeSelect" items="{{items}}" current="{{current}}" height="800rpx" multiple>
     <!-- 如果需要自定义行结构就在这里添加 picker-item -->
     <picker-item id="into-{{index}}" wx:for="{{items}}" wx:key="{{index}}" key="{{index}}" cancel-style='cancel-style' ok-style='ok-style'>
      <block>
        <text style="font-size: 40rpx; font-weight: bold; color: {{ item.choose ? '#ff0000' : '#939393'}}">自定义-{{item.name}}</text>
        <text style="font-size: 40rpx; font-weight: bold; color: {{ item.choose ? '#00ff00' : '#939393'}}">自定义-{{item.name}}</text>
        <text style="font-size: 40rpx; font-weight: bold; color: {{ item.choose ? '#0000ff' : '#939393'}}">自定义-{{item.name}}</text>
      </block>
    </picker-item> 
    <!-- 如果需要自定义行结构就在这里添加 picker-item -->
  </picker>
</view>
```
使用效果如下：

![](http://p4wb4s2l1.bkt.clouddn.com/image/blog/2/8.gif-gif)
![](http://p4wb4s2l1.bkt.clouddn.com/image/blog/2/7.gif-gif)

到这里的话，自定义的 `picker-view` 已经基本满足项目的需求了。不过还是有一些细节需要完善。想想也是头疼，在通用性和个性化之间想要平衡好还是很麻烦的。需要花费时间在实际应用中不断完善，最终才能打造出一套符合公司使用的组件库。不过在小公司大部分项目都在不久之后就停掉了，希望小程序这个项目能从 1.0.0 版本开始，坚持下来。

拖了这么久终于把这篇总结写完了，每次项目结束后都不想总结实践中遇到的问题，哎，懒癌啊~~~

[完整代码在这里，点一下][6]

[0]: https://developers.weixin.qq.com/miniprogram/dev/framework/custom-component/
[1]: https://developers.weixin.qq.com/miniprogram/dev/api/api-animation.html#wxcreateanimationobject
[2]: https://developers.weixin.qq.com/miniprogram/dev/framework/custom-component/wxml-wxss.html
[3]: https://developers.weixin.qq.com/miniprogram/dev/framework/custom-component/events.html
[4]: https://developers.weixin.qq.com/miniprogram/dev/framework/custom-component/relations.html
[5]: https://developers.weixin.qq.com/miniprogram/dev/framework/view/wxml/template.html
[6]: https://github.com/NoPPT/wx-picker-view