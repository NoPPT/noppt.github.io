---
title: CSS @font-face 使用
date: 2018-07-04 23:50:43
tags:
  - CSS
category: CSS
---

```css
@font-face {
  font-family: "AiDeep";
  src: url("./AiDeep.otf") format("opentype");
  /* 错误的写法 */
  /* src: url('./AiDeep.otf') format("otf"); */
  font-weight: 600;
  font-style: normal;
}
```

在添加自定义字体时，遇到无效的作用，起初以为是字体文件没有引用正确，后来发现是设置 `src` 时 `format` 没有填写正确，以为把字体文件后缀名传入 `format` 就可以了，还是太 naive 了。总结下常用字体文件格式以及 `@font-face` 的用法。

<!-- more -->

## @font-face

[@font-face][4] 是 CSS3 提供的一个 [at-rule][0]，用于指定一个自定义字体。

## 语法

### src

设置自定义字体的文件位置以及格式

```css
/* <url> values */
src: url(https://somewebsite.com/path/to/font.woff); /* absolute URL */
src: url(path/to/font.woff); /* relative URL */
src: url(path/to/font.woff) format("woff"); /* explicit format */
src: url("path/to/font.woff"); /* quoted URL */
src: url(path/to/svgfont.svg#example); /* fragment identifying font */

/* <font-face-name> values */
src: local(font); /* unquoted name */
src: local(some font); /* name containing space */
src: local("font"); /* quoted name */

/* Multiple items */
src: local(font), url(path/to/font.svg) format("svg"), url(path/to/font.woff)
    format("woff"), url(path/to/font.otf) format("opentype");
```

format 可接收参数有：`woff`, `woff2`, `truetype`, `opentype`, `embedded-opentype`, `svg`

### font-display

用于自定义字体加载过程时的显示问题

- `auto`: 默认值。典型的浏览器字体加载的行为会发生，也就是使用自定义字体的文本会先被隐藏，直到字体加载结束才会显示。
- `block`: 如果字体未加载完成，浏览器将首先绘制“隐形”文本；一旦字体加载完成，立即切换字体。
- `swap`：浏览器不会等待字体加载，直接使用字体栈中符合条件的字体先显示出来，等自定义字体加载完毕后再切换回来
- `fallback`: 需要使用自定义字体渲染的文本会在较短的时间（100ms according to Google ）不可见，如果自定义字体还没有加载结束，那么就先加载无样式的文本。一旦自定义字体加载结束，那么文本就会被正确赋予样式。
- `optional`: 和 `fallback` 基本相同，区别是让浏览器自由决定是否使用自定义字体

### font-family

指定一个字体名称，之后可以设置字体属性为当前值

```css
/* <string> values */
font-family: "font family";
font-family: "another font family";

/* <custom-ident> value */
font-family: examplefont;
```

### font-style

字体样式

```css
font-style: normal;
font-style: italic;
font-style: oblique;

/* Global values */
font-style: inherit;
font-style: initial;
font-style: unset;
```

### font-weight

设置字体的粗细

```css
/* Keyword values */
font-weight: normal;
font-weight: bold;

/* Keyword values relative to the parent */
font-weight: lighter;
font-weight: bolder;

/* Numeric keyword values */
font-weight: 100;
font-weight: 200;
font-weight: 300;
font-weight: 400;
font-weight: 500;
font-weight: 600;
font-weight: 700;
font-weight: 800;
font-weight: 900;

/* Global values */
font-weight: inherit;
font-weight: initial;
font-weight: unset;
```

### font-stretch

字体显示为正常、缩小、拉伸等样式

```css
/* Keyword values */
font-stretch: ultra-condensed;
font-stretch: extra-condensed;
font-stretch: condensed;
font-stretch: semi-condensed;
font-stretch: normal;
font-stretch: semi-expanded;
font-stretch: expanded;
font-stretch: extra-expanded;
font-stretch: ultra-expanded;

/* Global values */
font-stretch: inherit;
font-stretch: initial;
font-stretch: unset;
```

### font-variant

快速设置 font-variant-caps, font-variant-numeric, font-variant-alternates, font-variant-ligatures, 和 font-variant-east-asian。

```css
font-variant: small-caps;
font-variant: common-ligatures small-caps;

/* Global values */
font-variant: inherit;
font-variant: initial;
font-variant: unset;
```

### font-variation-settings

指定低级的 OpenType 或 TrueType 字体变体。

```css
/* Use the default settings */
font-variation-settings: normal;

/* Set values for OpenType axis names */
font-variation-settings: "xhgt" 0.7;
```

### unicode-range

设置要使用的字符的特定范围

```css
/* <unicode-range> values */
unicode-range: U+26; /* single codepoint */
unicode-range: U+0-7F;
unicode-range: U+0025-00FF; /* codepoint range */
unicode-range: U+4??; /* wildcard range */
unicode-range: U+0025-00FF, U+4??; /* multiple values */
```

## 格式

```css
@font-face {
  [ font-family: <family-name>; ] ||
  [ src: <src>; ] ||
  [ unicode-range: <unicode-range>; ] ||
  [ font-variant: <font-variant>; ] ||
  [ font-feature-settings: <font-feature-settings>; ] ||
  [ font-variation-settings: <font-variation-settings>; ] ||
  [ font-stretch: <font-stretch>; ] ||
  [ font-weight: <font-weight>; ] ||
  [ font-style: <font-style>; ]
}
where
<family-name> = <string> | <custom-ident>+
```

## 字体格式

对于 `@font-face` 而言，兼容性问题就是各浏览器所能识别的字体格式不尽相同。

### TrueType 格式(.ttf)

Windows 和 Mac 上常见的字体格式，是一种原始格式，因此它并没有为网页进行优化处理。<br>浏览器支持：IE9+,FireFox3.5+,Chrome4.0+,Safari3+,Opera10+,IOS Mobile Safari4.2+

### OpenType 格式(.otf)

以 TrueType 为基础，也是一种原始格式，但提供更多的功能。<br>浏览器支持：FireFox3.5+,Chrome4.0+,Safari3.1+,Opera10.0+,IOS Mobile Safari4.2+

### Web Open Font 格式(.woff)

针对网页进行特殊优化，因此是 Web 字体中最佳格式，它是一个开放的 TrueType/OpenType 的压缩版，同时支持元数据包的分离。<br>浏览器支持：IE9+, FireFox3.5+, Chrome6+, Safari3.6+,Opera11.1+

### Embedded Open Type 格式(.eot)

IE 专用字体格式，可以从 TrueType 格式创建此格式字体。<br>浏览器支持：IE4+

### SVG 格式(.svg)

基于 SVG 字体渲染的格式。<br>浏览器支持：Chrome4+, Safari3.1+, Opera10.0+, IOS Mobile Safari3.2+

这就意味着在 `@font-face` 中我们至少需要 .woff, .eot 两种格式字体，甚至还需要 .svg 等字体达到更多种浏览版本的支持。

[相关引用: @font-face][4]
[相关引用: font-display][3]
[相关引用: 字体格式][5]

[0]: https://developer.mozilla.org/en-US/docs/Web/CSS/At-rule
[1]: https://www.w3cplus.com/css/font-display-masses.html
[2]: https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/font-display
[3]: https://www.sohu.com/a/162902209_464084
[4]: https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face
[5]: https://segmentfault.com/a/1190000004179303