---
title: 跨域与同域策略
date: 2018-09-17 21:48:21
tags:
---

**跨域**：跨域是指一个域下的文档或脚本试图去请求另一个域下的资源，这里跨域是广义的。

广义的跨域：

- 资源跳转：A链接、重定向、表单提交
- 资源嵌入：`<link>`、`<script>`、`<img>`、`<frame>`等 dom 标签，还有样式中`background:url()、@font-face()` 等文件外链
- 脚本请求： js 发起的 ajax 请求、dom 和 js 对象的跨域操作等

<!-- more -->

**同域策略**：同源策略/SOP（Same origin policy）是一种约定，由 Netscape 公司 1995 年引入浏览器，它是浏览器最核心也最基本的安全功能，如果缺少了同源策略，浏览器很容易受到 XSS、CSFR 等攻击。所谓同源是指"协议+域名+端口"三者相同，即便两个不同的域名指向同一个ip地址，也非同源。

同源策略限制以下几种行为：

- Cookie、LocalStorage 和 IndexDB 无法读取
- DOM 和 Js对象无法获得
- AJAX 请求不能发送

## 常见跨域场景

| URL | 说明 | 是否允许通信 |
| --- | --- | --- |
| `http://www.domain.com/a.js`<br/>`http://www.domain.com/b.js`<br/>`http://www.domain.com/lab/c.js` | 同一域名，不同文件或路径 | 允许 |
| `http://www.domain.com:8000/a.js`<br/>`http://www.domain.com/b.js` | 同一域名，不同端口 | 不允许 |
| `http://www.domain.com/a.js`<br/>`https://www.domain.com/a.js` | 同一域名，不同协议 | 不允许 |
| `http://www.domain.com/a.js`<br/>`http://192.168.4.12/b.js` | 域名和域名对应相同ip | 不允许 |
| `http://www.domain.com/a.js`<br/>`http://x.domain.com/b.js`<br/>`http://domain.com/c.js` | 主域相同，子域不同 | 不允许 |
| `http://www.domain1.com/a.js`<br/>`http://www.domain2.com/b.js` | 不同域名 | 不允许 |

## 跨域解决方案

- 通过jsonp跨域
- document.domain + iframe跨域
- location.hash + iframe
- window.name + iframe跨域
- postMessage跨域
- 跨域资源共享（CORS）
- nginx代理跨域
- nodejs中间件代理跨域
- WebSocket协议跨域

## 相关名词

> CSRF（Cross-site request forgery）跨站请求伪造，也被称为“One Click Attack”或者Session Riding，通常缩写为CSRF或者XSRF，是一种对网站的恶意利用。尽管听起来像跨站脚本（XSS），但它与XSS非常不同，XSS利用站点内的信任用户，而CSRF则通过伪装来自受信任用户的请求来利用受信任的网站。与XSS攻击相比，CSRF攻击往往不大流行（因此对其进行防范的资源也相当稀少）和难以防范，所以被认为比XSS更具危险性。

> xss(Cross Site Scripting) 跨站脚本攻击，为了不和层叠样式表(Cascading Style Sheets, CSS)的缩写混淆，故将跨站脚本攻击缩写为XSS。恶意攻击者往Web页面里插入恶意Script代码，当用户浏览该页之时，嵌入其中Web里面的Script代码会被执行，从而达到恶意攻击用户的目的。