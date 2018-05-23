---
title: 微信小程序集成百度地图 API 及路线规划等功能
date: 2018-05-23 10:23:51
tags:
    - 微信小程序
    - 百度地图
    - API
categories: 微信小程序
---

目前微信小程序提供了 [`map`][2] 组件用于展示一些地图信息，以及获取当前[位置][3]的 API `wx.getLocation(OBJECT)`。如果想要基于 `map` 组件做一些扩展功能，就需要集成一些三方 API，如百度地图、高德地图来实现。本文使用百度地图微信小程序 JavaScript API，并增加一些额外功能。

<!-- more -->

## 小程序百度地图

### 简述集成步骤

1.  注册并登录[百度地图开发平台][8]
1.  到[控制台][7]创建应用并获取服务密钥
1.  下载[百度地图微信小程序 JavaScript API][6]
1.  添加 JS 文件到微信小程序中
1.  配置小程序合法域名
1.  开始开发功能

详细入门指南参照百度[官方文档][4]，下载 API 后发现有 `bmap-wx.js` 和 `bmap-wx.min.js` 一个是正常的文件，另一个是压缩代码后的文件。这里选择 `bmap-wx.js` 未压缩的文件，方便之后增加功能。

### 默认功能

目前百度地图微信小程序 JavaScript API 内只提供了以下四个接口。

* POI 检索
* POI 检索热词联想
* 逆地址解析
* 天气查询

同样这里官方提供了很好的 [DEMO][5]，就不重复实现了。

## 添加其他百度地图服务

百度地图默认提供的小程序接口功能太少，我们可以自己动手实现其他百度地图服务。通过查看百度地图微信小程序 API，我们可以发现，其实现方式主要是通过 `wx.request` 请求 `RESTful` 接口，然后处理接口返回数据，通过 `map` 组件提供的一些属性（`markers`, `polyline`, `include-points`）来显示返回数据，需要注意的是百度地图默认使用的是百度坐标（BD09），而 `map` 组件使用的是国测局坐标（火星坐标系，gcj02），所以我们需要把坐标统一转换为 `gcj02`。知道思路后就开始实现吧。

### 路线规划

这里以驾车路线规划为例，查看[路线规划 服务API][2]，根据文档传入比较关键的几个参数 

参数 | 备注
--- | ---
origin | 起点经纬度，小数点后不超过6位，40.056878,116.30815
destination | 终点经纬度，小数点后不超过6位，40.056878,116.30815
coord_type | 坐标类型，默认为bd09ll。这里传入 `gcj02`
ret_coordtype | 返回结果坐标类型，默认为bd09ll，这里传入 `gcj02`
ak | 填申请的密钥（和小程序不是同一个，控制台添加时选择服务端，注意要白名单不要做 IP 限制）

实现代码就比较简单了，在 `success` 方法中处理返回数据，按照 `map` 组件 `polyline` 属性需要的参数格式，尽量使 `route` 方法回掉时的数据能够直接使用。

```
route({ ori, des, success = function () { }, fail = function () { } }) {
  // http://lbsyun.baidu.com/index.php?title=webapi/direction-api-v2
  if (!ori || !des) {
    fail({
      errMsg: '传入起点终点经纬度',
      statusCode: -1
    });
    return;
  }
  var that = this;
  let routeparam = {
    origin: ori,
    destination: des,
    coord_type: 'gcj02',
    ret_coordtype: 'gcj02',
    ak: 'zIfvklWXpDFGCDzaHdZM6VOdeZWSO8US',
  };
  wx.request({
    url: 'https://api.map.baidu.com/direction/v2/driving',
    data: routeparam,
    header: {
      "content-type": "application/json"
    },
    method: 'GET',
    success(res) {
      const data = res.data;
      if (data["status"] === 0) {
        const res = data["result"];
        const { origin, destination, routes } = res;
        const { distance, duration, steps } = routes[0];
        let newSteps = [];
        steps && steps.forEach((value, index) => {
          const start = {
            latitude: value.start_location.lat,
            longitude: value.start_location.lng
          }
          newSteps.push(start);
          if (index == steps.length - 1) {
            const end = {
              latitude: value.end_location.lat,
              longitude: value.end_location.lng
            }
            newSteps.push(end);
          }
        });
        const result = {
          distance,
          duration,
          steps: newSteps
        };
        success(result);
      } else {
        fail({
          errMsg: data["message"],
          statusCode: data["status"]
        });
      }
    },
    fail(data) {
      fail(data);
    }
  });
}
```

[完整 Demo 代码在这里][9]

### 其他服务

和路线规划一样，基本上所有在 [WEB 服务API][10] 中提供的功能，都可以改造成可以适用微信小程序。

## 写在最后

我们可以发现其实没有什么难度，主要是调用接口然后处理数据罢了。虽然扩展百度地图小程序 API 很方便，但是并不建议企业项目直接添加。因为我们的实现是在小程序中使用百度地图服务端 API，所以我们在申请密钥时不能对 IP 做限制，不然无法让每部手机都能请求数据。如果自己写写 DEMO 的话可能无关紧要，但是如果做为企业使用的话，尽量让后台开发人员写接口调用百度地图 API 以保证密钥 AK 的安全性。

[0]: http://lbsyun.baidu.com/index.php?title=wxjsapi
[1]: http://lbsyun.baidu.com/index.php?title=webapi/direction-api-v2
[2]: https://developers.weixin.qq.com/miniprogram/dev/component/map.html
[3]: https://developers.weixin.qq.com/miniprogram/dev/api/location.html
[4]: http://lbsyun.baidu.com/index.php?title=wxjsapi/guide/key
[5]: http://lbsyun.baidu.com/index.php?title=wxjsapi/guide/getpoi
[6]: http://lbsyun.baidu.com/index.php?title=wxjsapi/wxjs-download
[7]: http://lbsyun.baidu.com/apiconsole/key
[8]: http://lbsyun.baidu.com/index.php?title=%E9%A6%96%E9%A1%B5
[9]: https://github.com/NoPPT/wx-app-demo
[10]: http://lbsyun.baidu.com/index.php?title=webapi