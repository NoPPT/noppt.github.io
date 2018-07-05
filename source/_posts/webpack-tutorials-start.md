---
title: Webpack v4.14.0 实践
date: 2018-06-23 14:22:34
tags:
    - webpack
    - 部署
    - CLI
category: Webpack
---

之前使用 leaflet 开发地图相关功能时，采用最原始的 `<script>` 和 `<link>` 标签依次添加所有 JS 和 CSS 文件，随着文件的增多每次更改内容时都要修改对应的版本号，十分麻烦。之前基于 `create-react-app` 这个脚手架创建的项目每次都会把所有文件打包的一个文件中，当时只知道使用了 webpack（是一个现代 JavaScript 应用程序的静态模块打包器）实现，不知道如何从 0 到 1 使用 webpack 创建项目开发环境以及打包资源文件。由于之前并没有用过 webpack，所以本文直接根着[官方教程][13]，使用最新版本 v4.14.0 进行项目实践。

## 安装

### 依赖环境

- Node.js v8.9.0
- Webpack v4.14.0

### 本地安装

```shell
mkdir webpack-demo && cd webpack-demo
npm init -y
npm install --save-dev webpack webpack-cli
```

<!-- more -->

## 文件目录

可以根据以下目录结构创建项目。

```text
.
├── README.md
├── config
│   └── webpack.config.js
├── dist
├── package-lock.json
├── package.json
├── public
│   └── index.html
└── src
    └── index.js
```

- config: webpack 的配置文件
- dist: 打包后的文件以及资源
- public: 一些公共文件
- src: 项目主要源文件

### index.html

```html
<!doctype html>
<html>
  <head>
    <title>webpack 4</title>
  </head>
  <body>
    <script src="../dist/main.js"></script>
  </body>
</html>
```

### index.js

```js
import _ from "lodash";

function component() {
  var element = document.createElement("div");

  element.innerHTML = _.join(["Hello", "webpack"], " ");

  return element;
}

document.body.appendChild(component());
```

### webpack.config.js

- entry: 告诉 webpack 应该使用哪些模块，作为构建其内部依赖图的开始，webpack 会根据入口起点找出哪些模块和库是入口起点（直接和间接）的依赖。默认值是 `./src`。
- output: 用于设置 webpack 根据 entry 创建的 bundles 输出位置（path），以及如何命名（filename）。输出位置默认值 `./dist`。

```js
const path = require("path");

module.exports = {
  entry: path.resolve(__dirname, "../src/index.js"),
  output: {
    filename: "main.js",
    path: path.resolve(__dirname, "../dist")
  }
};
```

### package.json

- private 属性设置为 true，避免项目意外上传到 npm。
- dependencies 中添加项目线上环境需要的依赖，`npm --save packagename`。
- devDependencies 中添加开发环境中需要的依赖，`npm --save-dev packagename`。
- scripts 中添加一些脚本，可以通过执行 `npm run build` 命令行执行 `build` 对应的操作 `webpack --config ./config/webpack.config.js`。

```json
{
  "name": "webpack-practice",
  "version": "1.0.0",
  "description": "",
  "private": true,
  "dependencies": {
    "lodash": "^4.17.10"
  },
  "devDependencies": {
    "webpack": "^4.14.0",
    "webpack-cli": "^3.0.8"
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack --config ./config/webpack.config.js"
  },
  "repository": {
    "type": "git",
    "url": "https://gitee.com/noppt/webpack-practice.git"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```

## 第一次打包

```shell
npm run build

> webpack-practice@1.0.0 build /Users/oeffect/webpack-practice
> webpack --config ./config/webpack.config.js

Hash: 298173865a5e85e20b09
Version: webpack 4.14.0
Time: 334ms
Built at: 2018-07-04 13:54:27
  Asset      Size  Chunks             Chunk Names
main.js  70.5 KiB       0  [emitted]  main
[1] (webpack)/buildin/module.js 497 bytes {0} [built]
[2] (webpack)/buildin/global.js 489 bytes {0} [built]
[3] ./src/index.js 215 bytes {0} [built]
    + 1 hidden module

WARNING in configuration
The 'mode' option has not been set, webpack will fallback to 'production' for this value. Set 'mode' option to 'development' or 'production' to enable defaults for each environment.
You can also set it to 'none' to disable any default behavior. Learn more: https://webpack.js.org/concepts/mode/
```

然后打开 `./public/index.html` 可以看到对应的内容 `Hello webpack`。

## 管理资源

使用 `loader` 来预处理文件，打包静态资源如：CSS、图片、字体、数据等。

### 加载 CSS

需要添加 [style-loader][4] 和 [css-loader][5]

```shell
npm install --save-dev style-loader css-loader
```

```js
// webpack.config.js
const path = require("path");

module.exports = {
  entry: path.resolve(__dirname, "../src/index.js"),
  output: {
    filename: "main.js",
    path: path.resolve(__dirname, "../dist")
  },
  module: {
    rules: [
      {
        test: /\.css$/
        use: ["style-loader", "css-loader"]
      }
    ]
  }
};
```

注意在 `webpack.config.js` 中添加了 `module`。`rules` 对应的数组中添加需要用到的 `loader` 以及匹配规则， 数组中每一个对象中的 `test` 为匹配文件用到的正则表达式，如果匹配成功，就会使用 `use` 中对应的 `loader` 处理文件。

如果需要配置 loader 可以使用下面这种写法：

```js
use: [
  { loader: "style-loader" },
  {
    loader: "css-loader",
    options: {
      modules: true
    }
  }
];
```

然后在 `src` 目录下增加 `style.css` 文件

```css
.hello {
  color: red;
}
```

并在 `index.html` 中引用 `style.css`，并配置对应的样式

```js
import './style.css';

...

element.classList.add('hello');

...
```

重新执行 `npm run build` 后打开 `index.html`，字体的颜色就变成红色了，此时的资源输出文件仍然是 `main.js`，即 `css` 也打包到 `main.js` 文件中了。

类似的 less 和 sass 都能找到对应的 loader，如 [postcss-loader][1]、[sass-loader][2]、[less-loader][3]等，根据需要添加。

###  加载图片和字体资源

使用 [file-loader][6] 可以处理图片和文字资源。

```shell
npm install --save-dev file-loader
```

然后在 `webpack.config.js` 文件的 `module.rules` 中添加以下配置：

```js
{
  test: /\.(png|svg|jpg|gif)$/,
  use: ["file-loader"]
},
{
  test: /\.(woff|woff2|eot|ttf|otf)$/,
  use: ["file-loader"]
}
```

由于现在 `index.html` 位置为 `public` 文件夹下，而资源输出为 `dist` 文件夹下，所以需要设置资源的 `publicPath` 防止在 `index.html` 中找不到对应的资源文件。可以通过设置 `file-loader` 的 `options.publicPath` 或者设置 `output.publicPath` 为 `../dist/` 来解决。

之后我们在项目中引用自己添加的图片以及字体文件就可以打包输出到 `dist` 文件夹中了。

除了上面的 CSS、图片、字体，如果需要处理其他类型资源，[在这里选择 loader][0]，然后根据文档配置 `module.rules` 规则就可以了。

## 管理输出

上面的打包已经满足基本情况，但是当项目文件越来越多后，把所有的 JS、CSS 文件打包在同一个文件中则每次更新内容都要重新加载整个包，无法使用缓存，导致加载速度慢，如果输出包过大，则需要合理的划分模块以及分离 CSS，并且压缩代码文件。还有如果资源变更则需要删除原打包文件，否则会导致 `dist` 文件夹混乱难以管理。需要解决的有以下几点问题：

- 设置 mode
- 多输出文件
- 分离 CSS
- HTML 文件
- 清空原打包文件
- 代码压缩

### 设置 mode

第一次打包时，控制台打印了一条警告信息

```text
WARNING in configuration
The 'mode' option has not been set, webpack will fallback to 'production' for this value. Set 'mode' option to 'development' or 'production' to enable defaults for each environment.
You can also set it to 'none' to disable any default behavior. Learn more: https://webpack.js.org/concepts/mode/
```

需要在 `webpack.config.js` 中增加 `mode` 参数: `production` 或 `development`。

| 选项 | 描述 |
| --- | --- |
| `development` | 会将 `process.env.NODE_ENV` 的值设为 `development`。启用 `NamedChunksPlugin` 和 `NamedModulesPlugin`。 |
| `production` | 会将 `process.env.NODE_ENV` 的值设为 `production`。启用 `FlagDependencyUsagePlugin`, `FlagIncludedChunksPlugin`, `ModuleConcatenationPlugin`, `NoEmitOnErrorsPlugin`, `OccurrenceOrderPlugin`, `SideEffectsFlagPlugin` 和 `UglifyJsPlugin` |

```js
module.exports = {
  mode: 'production',

  ...
}
```

或者修改脚本

```shell
"build": "webpack --config ./config/webpack.config.js --mode=production"
```

### 多输出文件

```js
entry: {
  app: path.resolve(__dirname, "../src/index.js"),
  print: path.resolve(__dirname, "../src/print.js")
},
output: {
  filename: '[name].[hash].js',
  publicPath: "../dist/",
  path: path.resolve(__dirname, "../dist")
},
```

打包后的文件输出格式类似下面:

```text
                               Asset      Size  Chunks             Chunk Names
       print.391eb52370f2a88b31f4.js  1.03 KiB       0  [emitted]  print
         app.391eb52370f2a88b31f4.js  77.1 KiB    1, 0  [emitted]  app
```

### 分离 CSS

[mini-css-extract-plugin][7] 插件可以将 CSS 文件分离到单独的文件中。

```shell
npm install --save-dev mini-css-extract-plugin
```

配置 `webpack.config.js` 文件

```js
const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  ...
  
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: "css-loader",
            options: {
              minimize: true
            }
          }
        ]
      },

      ...
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "[name].[hash].css",
      chunkFilename: "[id].[hash].css"
    })
  ]
};
```

### HTML 文件

使用 [HtmlWebpackPlugin][8] 插件可以生成 HTML 文件到输出文件夹，并自动引用打包后的 JS 和 CSS 文件。

```shell
npm i --save-dev html-webpack-plugin
```

配置 `webpack.config.js` 文件

```js
const HtmlWebpackPlugin = require("html-webpack-plugin");

...

plugins: [
  ...,

  new HtmlWebpackPlugin({
    inject: true,
    template: path.resolve(__dirname, "../public/index.html")
  }),
]
```

### 清空原打包文件

使用 [CleanWebpackPlugin][9] 插件用于删除原有输出文件。

```shell
npm install --save-dev clean-webpack-plugin
```

配置 `webpack.config.js` 文件

```js
const CleanWebpackPlugin = require("clean-webpack-plugin");

...

plugins: [
  new CleanWebpackPlugin(["*"], {
    root: path.resolve(__dirname, "../dist")
  }),

  ...,
]
```

### 代码压缩

- 设置 `css-loader` 的 `options.minimize` 值为 `true` 用于压缩 css 代码。
- 设置 `mode` 值为 `production`，默认启用 JS 文件压缩。

## 开发模式

新创建一个 `webpack` 的配置文件 `webpack.config.dev.js` 并把原 `webpack.config.js` 的内容复制到新文件。

### 追溯错误

JS 提供了 [source map][10] 功能，将编译后的代码映射回原始源代码。

配置 `webpack.config.dev.js` 的 [devtool][11]：

```js
module.exports = {
  mode: "development",
  devtool: 'inline-source-map',
  ...
}
```

这样在浏览器控制台输出的错误就能找到出错文件的位置。

### webpack-dev-server

之前每次查看项目都要运行 `npm run build` 命令行编译代码，然后刷新页面，十分麻烦。在开发环境时，使用 [webpack-dev-server][12] 解决实时编译和重新加载的问题。

```shell
npm install --save-dev webpack-dev-server
```

配置 `webpack.config.dev.js` 文件

```js
module.exports = {
  ...

  devServer: {
    inline: true,
    open: true, //自动打开页面,
  }

  ...
}
```

在 `package.json` 中添加 scripts

```json
"scripts": {
  
  ...

  "start": "webpack-dev-server --open --config ./config/webpack.config.dev.js"
},
```

然后调用

```shell
npm run start
```

开启服务器，会自动打开 `http://localhost:8081/` 页面。

### 模块热替换

模块热替换(Hot Module Replacement 或 HMR)是 webpack 提供的最有用的功能之一。它允许在运行时更新各种模块，而无需进行完全刷新。主要是通过以下几种方式，来显著加快开发速度：

- 保留在完全重新加载页面时丢失的应用程序状态。
- 只更新变更内容，以节省宝贵的开发时间。
- 调整样式更加快速 - 几乎相当于在浏览器调试器中更改样式。

配置 `webpack.config.dev.js` 文件，devServer 中增加 `hot` 为 true 就可以启动热更新模式。

```js
module.exports = {
  ...

  devServer: {
    ...

    hot: true
  }

  ...
}
```

[常用 Loaders][1]
[常用 Plugins][15]

到目前为止已经可以基于这些配置进行日常简单的项目开发工作了。教程中还有一些进阶的用法，比如缓存、代码分离等等，由于目前并没有用到的场景，所以本篇不继续实践这些内容，等之后有空再仔细研究。

[0]: https://webpack.docschina.org/loaders/
[1]: https://github.com/postcss/postcss-loader
[2]: https://github.com/webpack-contrib/sass-loader
[3]: https://github.com/webpack-contrib/less-loader
[4]: https://github.com/webpack-contrib/style-loader
[5]: https://github.com/webpack-contrib/css-loader
[6]: https://github.com/webpack-contrib/file-loader
[7]: https://github.com/webpack-contrib/mini-css-extract-plugin
[8]: https://github.com/jantimon/html-webpack-plugin
[9]: https://github.com/johnagan/clean-webpack-plugin
[10]: http://blog.teamtreehouse.com/introduction-source-maps
[11]: https://webpack.docschina.org/configuration/devtool
[12]: https://github.com/webpack/webpack-dev-server
[13]: https://webpack.docschina.org/guides/
[14]: https://auth0.com/blog/javascript-module-systems-showdown/
[15]: https://webpack.docschina.org/plugins/