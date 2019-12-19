---
title: 前端统计指标概念
date: 2019-12-19 15:39:01
tags:
  - Web
categories: 前端
---

## JS 稳定性

在一个 PV 周期内，如果发生过错误（JS Error），则此 PV 周期为错误样本。

错误率 = 错误样本量 / 总样本量

页面异常除了自动上报的 JS Error 外，也包括手动调用 error 方法上报的错误。

## API 成功率

API 成功率 = 接口调用成功的样本量 / 总样本量

统计 API 成功率的样本除了自动上报的 AJAX 请求，还包括手动调用 API 方法上报的数据。

<!-- more -->

## PV

统计 PV：每次页面触发 1 次 load 事件计 1 次 PV。

## UV

统计 UV：每当有新的用户访问应用时，我们会在 cookie 中计入 1 个 UID。该 UID 有效期为 6 个月，有效期内的所有访问记为 1 次 UV。

## window.performance

```
interface Performance {
  readonly attribute PerformanceTiming timing;
  readonly attribute PerformanceNavigation navigation;
};

partial interface Window {
  [Replaceable] readonly attribute Performance performance;
};
```

https://www.w3.org/TR/navigation-timing/?spm=a2c4g.11186623.2.21.61d052fcdsoKED

### PerformanceTiming

![](http://qiniu.0x0803.top/image/blog/20190125102038.png_blog)

```
interface PerformanceTiming {
  readonly attribute unsigned long long navigationStart;
  readonly attribute unsigned long long unloadEventStart;
  readonly attribute unsigned long long unloadEventEnd;
  readonly attribute unsigned long long redirectStart;
  readonly attribute unsigned long long redirectEnd;
  readonly attribute unsigned long long fetchStart;
  readonly attribute unsigned long long domainLookupStart;
  readonly attribute unsigned long long domainLookupEnd;
  readonly attribute unsigned long long connectStart;
  readonly attribute unsigned long long connectEnd;
  readonly attribute unsigned long long secureConnectionStart;
  readonly attribute unsigned long long requestStart;
  readonly attribute unsigned long long responseStart;
  readonly attribute unsigned long long responseEnd;
  readonly attribute unsigned long long domLoading;
  readonly attribute unsigned long long domInteractive;
  readonly attribute unsigned long long domContentLoadedEventStart;
  readonly attribute unsigned long long domContentLoadedEventEnd;
  readonly attribute unsigned long long domComplete;
  readonly attribute unsigned long long loadEventStart;
  readonly attribute unsigned long long loadEventEnd;
};
```

**navigationStart**

如果存在上一个的 document ，则返回 document unload 时的时间，否则返回和 fetchStart 相同的时间

**unloadEventStart**

返回之前 document 开始触发 unload 事件时间，如果不同 origin 返回 0

**unloadEventEnd**

返回之前 document 触发 unload 事件结束时间，如果不同 origin 返回 0

**redirectStart**

返回重定向开始 fetch 时的时间，如果不同 origin 返回 0

**redirectEnd**

返回重定向返回的响应数据全局接收到的时间，如果不同 origin 返回 0

**fetchStart**

返回用户开始请求资源的时间，如果使用 HTTP GET 返回的时间在查询缓存之前。

**domainLookupStart**

如果是一个新的域名，则返回查询域名开始的时间，否则返回结果同 fetchStart

**domainLookupEnd**

如果是一个新的域名，则返回查询域名结束的时间，否则返回结果同 fetchStart

**connectStart**

返回用户同服务器创建连接开始的时间，如果有缓存，则返回结果同 domainLookupEnd

**connectEnd**

返回用户同服务器创建连接结束的时间，如果有缓存，则返回结果同 domainLookupEnd，如果传输失败同时用户重新创建一个 connection ，connectStart 和 connectEnd 返回新连接对应的时间

**secureConnectionStart**

如果非 HTTPS 返回 0，否则返回开始连接安全验证服务的时间。

**requestStart**

返回从服务器或者缓存开始请求当前 document 资源的时间。如果失败则返回新的 request 的时间

**responseStart**

返回从服务器或者缓存收到第一个字节的时间

**responseEnd**

返回从服务器或者缓存收到最后一个字节的时间，或者传输 connection 结束的时间

**domLoading**

document 正在加载的状态

**domInteractive**

document 解析完毕，但还有一些资源在加载中

**domContentLoadedEventStart**

domContent 开始解析时间

**domContentLoadedEventEnd**

domContent 解析结束时间

**domComplete**

document 解析完毕，资源加载完毕

**loadEventStart**

返回 document 开始触发 load 的时间，否则返回 0

**loadEventEnd**

返回 document load 事件结束的时间，否则返回 0

### PerformanceNavigation

```
interface PerformanceNavigation {
  const unsigned short TYPE_NAVIGATE = 0;
  const unsigned short TYPE_RELOAD = 1;
  const unsigned short TYPE_BACK_FORWARD = 2;
  const unsigned short TYPE_RESERVED = 255;
  readonly attribute unsigned short type;
  readonly attribute unsigned short redirectCount;
};
```

**type**

返回当前浏览器上下文中上一个没有重定向的路由跳转的类型

**TYPE_NAVIGATE**

点击 link，在浏览器中输入 URL，或者 js 操作跳转。

**TYPE_RELOAD**

刷新操作或者使用 `location.reload()`

**TYPE_BACK_FORWARD**

history 操作

**TYPE_RESERVED**

其余类型

**redirectCount**

返回自当前浏览器上下文中上一个没有重定向的路由到当前重定向的次数，如果没有返回 0

## 访问速度

### 阶段耗时

| 上报字段 | 描述                                     | 计算方式                                  | 备注                             |
| -------- | ---------------------------------------- | ----------------------------------------- | -------------------------------- |
| dns      | DNS 解析耗时                             | domainLookupEnd - domainLookupStart       |                                  |
| tcp      | TCP 连接耗时                             | connectEnd - connectStart                 |                                  |
| ssl      | SSL 安全连接耗时                         | connectEnd - secureConnectStart           | 只在 HTTPS 下有效                |
| ttfb     | Time to First Byte（TTFB），网络请求耗时 | responseStart - requestStart              | [Google Development][0] 定义方式 |
| trans    | 数据传输耗时                             | responseEnd - responseStart               |                                  |
| dom      | dom 解析耗时                             | domInteractive - responseEnd              |                                  |
| res      | 资源加载耗时                             | loadEventStart - domContentLoadedEventEnd | 表示页面中的同步加载资源         |

### 关键性能指标

| 上报字段  | 描述                                      | 计算方式                            | 备注                                                              |
| --------- | ----------------------------------------- | ----------------------------------- | ----------------------------------------------------------------- |
| firstbyte | 首包时间                                  | responseStart - domainLookupStart   |                                                                   |
| fpt       | First Paint Time, 首次渲染时间 / 白屏时间 | responseEnd - fetchStart            | 从请求开始到浏览器开始解析第一批 HTML 文档字节的时间差            |
| tti       | Time to Interact，首次可交互时间          | domInteractive - fetchStart         | 浏览器完成所有 HTML 解析并且完成 DOM 构建，此时浏览器开始加载资源 |
| ready     | HTML 加载完成时间， 即 DOM Ready 时间     | domContentLoadEventEnd - fetchStart | 如果页面有同步执行的 JS，则同步 JS 执行时间 = ready - tti         |
| load      | 页面完全加载时间                          | loadEventStart - fetchStart         | load = 首次渲染时间 + DOM 解析耗时 + 同步 JS 执行 + 资源加载耗时  |

[0]: https://developers.google.com/web/tools/chrome-devtools/network-performance/reference?spm=a2c4g.11186623.2.24.61d052fcdsoKED#timing
[1]: https://help.aliyun.com/document_detail/60288.html?spm=a2c4g.11186623.6.621.61d052fcdsoKED
