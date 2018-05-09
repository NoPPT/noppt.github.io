---
title: 上传项目到 npm
date: 2018-04-10 10:42:40
tags:
    - npm
categories: 其它
---

本文介绍如果上传自己写的 npm 组件包到 [npm 官方库][3]。当你的组件代码已经完成了之后，只需要简单执行几个步骤就能发布项目共享上去给别人使用了。

<!-- more -->

## 创建项目的 `package.json` 文件

### 通过命令行创建 `package.json` 文件

```shell
# 切换到项目目录
$ cd PublishProjectName
# 执行 `npm init`
$ npm init
# 执行结果如下，按照进度填写项目信息就行了~
This utility will walk you through creating a package.json file.
It only covers the most common items, and tries to guess sensible defaults.

See `npm help json` for definitive documentation on these fields
and exactly what they do.

Use `npm install <pkg> --save` afterwards to install a package and
save it as a dependency in the package.json file.

Press ^C at any time to quit.
name: (PublishProjectName) test
version: (1.0.0)
description:
entry point: (index.js)
test command:
git repository:
keywords:
author:
license: (ISC)
About to write to /Users/xxx/Desktop/PublishProjectName/package.json:

{
  "name": "test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}


Is this ok? (yes)

#此时目录中就有了package.json文件了
```

### 自己创建 `package.json` 文件，并修改内容

```json
{
  # 在 npm 服务器中的名字，避免与 npm 已有项目重名。
  "name": "react-native-zhb-actionsheet",
  "version": "1.0.3",
  "description": "react-native ActionSheet for Android and iOS",
  # 待上传项目源文件位置
  "main": "src/index.js",
  # 通过 npm 可以下载的文件，避免下载多余文件
  "files": [
    "src"
  ],
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  # 仓库地址，这里是github
  "repository": {
    "type": "git",
    "url": "git+https://github.com/NoPPT/react-native-actionsheet.git"
  },
  # 搜索关键词
  "keywords": [
    "react-native",
    "reactnative",
    "rn",
    "pickerview",
    "actionsheet"
  ],
  "author": "zhuang",
  "license": "MIT",
  "bugs": {
    "url": "https://github.com/NoPPT/react-native-actionsheet/issues"
  },
  "homepage": "https://github.com/NoPPT/react-native-actionsheet#readme"
}
```

## 创建 `npm` 账户

1. 通过 `npm adduser` 命令创建用户。

    ```shell
    npm adduser
    Username: test
    Password:
    Email: (this IS public) test@test.com
    ```
2. 网页进行 [npm 注册][2]。

## 登录账户 `npm login`

``` shell
$ npm login
Username: accountName
Password:
Email: (this IS public)
```

## 上传项目

```shell
$ npm publish
```

## 查看项目

可以在 `https://npmjs.com/package/<package>` 查看项目是否已经添加到 `npm` 服务器。

## 相关

[Publishing npm packages][0]

[0]: https://docs.npmjs.com/getting-started/publishing-npm-packages
[1]: https://docs.npmjs.com/getting-started/creating-node-modules
[2]: https://www.npmjs.com/signup
[3]: https://www.npmjs.com