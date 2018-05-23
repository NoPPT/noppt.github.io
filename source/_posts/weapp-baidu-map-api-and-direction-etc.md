---
title: 微信小程序集成百度地图 API 及路线规划等功能
date: 2018-05-23 10:23:51
tags:
    - 微信小程序
    - 百度地图
    - API
categories: 微信小程序
---

目前微信小程序提供了 [`map`][2] 组件用于展示一些地图信息，以及获取当前[位置][3]的 API `wx.getLocation(OBJECT)`。如果想要基于 `map` 组件做一些扩展功能，就需要集成一些三方API，如百度地图、高德地图来实现。本文使用百度地图微信小程序 JavaScript API，并增加一些额外功能。

## 百度地图 API

目前百度地图微信小程序 JavaScript API 内只提供了以下四个接口。

- POI检索
- POI检索热词联想
- 逆地址解析
- 天气查询

<!-- more -->

[0]: http://lbsyun.baidu.com/index.php?title=wxjsapi
[1]: http://lbsyun.baidu.com/index.php?title=webapi/direction-api-v2
[2]: https://developers.weixin.qq.com/miniprogram/dev/component/map.html
[3]: https://developers.weixin.qq.com/miniprogram/dev/api/location.html