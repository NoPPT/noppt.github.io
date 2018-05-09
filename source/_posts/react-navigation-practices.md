---
title: React Navigation v2.0.0 实践总结
date: 2018-04-10 11:29:30
tags:
    - react-navigation
    - react-native
    - 实践
categories: react-native
---

最近新开了一个项目，才发现 `react-native` 已经更新到 `0.55.1` 版本了，作为[官方推荐][1]使用的路由导航组件 [React Navigation][0] 也已经迭代更新到 `2.0.0` 版本。而我在半年前创建的项目使用的版本只是 `1.0.0-beta.11`，偷懒把之前的代码直接拷贝过来使用，会有警告和错误。新版本的文档相比之前又完善了不少，想想还是重新温习下[文档][2]，顺便记录总结下 `react-navigation` 的使用方法。

<!-- more -->

## 安装引用

```
yarn add react-navigation
# or with npm
# npm install --save react-navigation
```
## 属性和方法

### prop

### NavigationActions

## 基础导航组件

### StackNavigator

### TabNavigator

### DrawerNavigator

### SwitchNavigator

## 高阶组件

### withNavigation

### withNavigationFocus

## 常用导航组合

### 常用导航

### Redux

## 一些实践方法

### 自定义 HeaderLeft、HeaderRight

### 统一返回按钮

### 统一 HeaderTitle 居中

### 设置 Header 样式

### 区分多 StackNavigator 的 navigation 方法




[0]: https://reactnavigation.org
[1]: https://facebook.github.io/react-native/docs/navigation.html
[2]: https://reactnavigation.org/docs/getting-started.html