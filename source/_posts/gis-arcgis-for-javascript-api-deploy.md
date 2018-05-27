---
title: ArcGIS for JavaScript API v3.24 部署指南
date: 2018-05-23 09:44:33
tags:
    - ArcGIS
    - JavaScript
    - 部署
categories: GIS
---

## 下载 API & SDK

[APIs & SDKs 下载地址](https://developers.arcgis.com/downloads/apis-and-sdks)

只有注册并登录帐号后才能从 ArcGIS for Developers 中下载相关的 API 和 SDK。

登录后选择要下载的产品相应的 API 和 Documentation：

Product | Version
--- | ---
ArcGIS API for JavaScript | 3.24

<!-- more -->

## 解压 API 到文件夹

对应的目录结构树如下：

```
/Users/oeffect/Downloads/arcgis_js_v324_api
├── arcgis_js_api
│   └── library
│       └── 3.24
│           ├── 3.24
│           ├── 3.24compact
│           ├── install_api_linux.html
│           └── install_api_windows.html
├── install.html
└── legal
    └── EULA.pdf
```

## 配置 Nginx

主要文件为 `arcgis_js_api/library/3.24`

```
server {
    listen 80;

    location /arcgis/ {
        autoindex on;
        alias /usr/local/var/www/library/arcgis/3.24/;
        index install_api_linux.html;
    }   
}
```

如果出现 403 Forbidden 情况，可以关闭 nginx 的第一行的注释，并修改配置为资源文件夹的用户以及用户组（Mac系统），如:

```
user root staff;
```


同时开启目录浏览功能，如上配置 `autoindex` 值为 `on`。

打开 `http://localhost/arcgis/` 可以看到安装指南。

## 根据文档修改配置

如果没有相应的安全证书，可修改 `https` 为 `http` 

### 修改默认 `3.24` 文件下的配置

1. 打开 `arcgis_js_api/library/3.24/3.24/init.js` 文件搜索并替换 `https://[HOSTNAME_AND_PATH_TO_JSAPI]/dojo` 为当前部署的地址 `https://www.example.com/arcgis_js_api/library/3.24/3.24/dojo`
 
1. 打开 `arcgis_js_api/library/3.24/3.24/dojo/dojo.js` 文件搜索并替换 `https://[HOSTNAME_AND_PATH_TO_JSAPI]/dojo` 为当前部署的地址 `https://www.example.com/arcgis_js_api/library/3.24/3.24/dojo`

### 修改 `compact` 文件下的配置

1. 打开 `/var/www/html/arcgis_js_api/library/3.24/3.24compact/init.js`  文件搜索并替换 `https://[HOSTNAME_AND_PATH_TO_JSAPI]dojo` 为当前部署的地址  `https://www.example.com/arcgis_js_api/library/3.24/3.24compact/dojo`

1. 打开 `/var/www/html/arcgis_js_api/library/3.24/3.24compact/dojo/dojo.js` 文件搜索并替换 `https://[HOSTNAME_AND_PATH_TO_JSAPI]dojo` 为当前部署的地址 `https://www.example.com/arcgis_js_api/library/3.24/3.24compact/dojo`

## 测试使用

``` html
<!DOCTYPE HTML>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Test Map</title>
    <link rel="stylesheet" href="https://www.example.com/arcgis_js_api/library/3.24/3.24/esri/css/esri.css" />
    <script src="https://www.example.com/arcgis_js_api/library/3.24/3.24/init.js"></script>
    <style>
      html,
      body,
      #map {
        height: 100%;
        width: 100%;
        margin: 0;
        padding: 0;
      }
    </style>
    <script>
      require([
          "esri/map",
          "esri/layers/ArcGISTiledMapServiceLayer",
          "dojo/domReady!"
      ],function(Map, ArcGISTiledMapServiceLayer) {
          var map = new Map("map");
          //If you do not have Internet access then you will need to point this url to your own locally accessible tiled service.
          var tiled = new ArcGISTiledMapServiceLayer("https://services.arcgisonline.com/arcgis/rest/services/Ocean/World_Ocean_Base/MapServer");
          map.addLayer(tiled);
      });
    </script>
  </head>
  <body>
    <div id="map"></div>
  </body>
</html>
```