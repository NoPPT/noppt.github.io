---
title: Code Push 服务器搭建以及集成方式
date: 2018-02-28 23:54:18
tags: 
    - Code Push 
    - CI
categories: React Native
---

前段时间推动公司使用 React Native 技术把 APP 给重写了，到现在已经稳定运行了一段时间。期间踩了很多坑，其中之一就是热更新服务器的选型与搭建，现在把热更新服务器的搭建简单总结一下。搭建之前调研了比较流行两种的方案：微软的 [CodePush][0] 以及 React Native 中文网的 [pushy][4]。虽说集成很简单，不用自己搭建后台，但是作为公司项目使用的话，把更新服务寄希望于不可控平台不是很合适。最终还是在 GitHub 上找到了一个开源并且很好用的项目 [code-push-server][1] 稍加改动后就基本满足目前项目使用需求。

<!-- more -->

## 服务器搭建

### 依赖环境

```json
Python 2.7.10
node v6.9.1
npm 4.0.2
C++ 11
mysql 5.7.16
```

### 下载源码文件
```shell
$ git clone https://github.com/lisong/code-push-server.git
```

### 修改配置信息 ./config/config.js

```json
// 修改数据库连接信息
db: {
    username: process.env.RDS_USERNAME || "root", //db帐号
    password: process.env.RDS_PASSWORD || null, //密码
    database: process.env.DATA_BASE || "codepush", //数据库名，默认codepush
    host: process.env.RDS_HOST || "127.0.0.1", //db host
    port: process.env.RDS_PORT || 3306, //db port
},
// 配置文件存储信息
local: {
    // 待更新文件存储路径
    storageDir: process.env.STORAGE_DIR || "/path/to/storage",
    // 待更新文件（storageDir路径）的下载地址, CodePush Server 地址 + '/download'
    // 地址请根据实际情况填写，我这里是 http://192.168.1.3:3000
    downloadUrl: process.env.LOCAL_DOWNLOAD_URL || "http://192.168.1.3:3000/download",
    // downloadUrl对应的下载文件存储的地址.
    public: process.env.PUBLIC || '/path/to/download'
},
jwt: {
    // Recommended: 63 random alpha-numeric characters
    // Generate using: https://www.grc.com/passwords.htm
    tokenSecret: process.env.TOKEN_SECRET ||'INSERT_RANDOM_TOKEN_KEY'
},
common: {
    tryLoginTimes: 5,
    // 临时文件存储路径.
    dataDir: process.env.DATA_DIR || "/path/to/data",
},
//这里配置邮箱信息
smtpConfig:{
    host: "mail.ksudi.com",
    port: 25,
    secure: false,
    auth: {
      user: "developer@mail.com",
      pass: "password"
    }
},
redis: {
    default: {
      host: "127.0.0.1",
      port: 6379,
    }
}
```

### 安装

```shell
$ cd code-push-server
$ npm install
$ ./bin/db init #初始化mysql数据库
--dbname	[默认值: "codepush"]
--dbhost	[默认值: "localhost"]
--dbuser	[默认值: "root"]
--dbpassword	[默认值: "root"]
eg: ./bin/db init --dbname codepush --dbhost localhost --dbuser root --dbpassword 123456
```

### 启动服务

#### 直接启动服务

直接启动服务可以及时查看日志，但进程容易 crash，服务器地址为 http://127.0.0.1:3000/ 如果本地开发建议使用此方法，正式环境使用 pm2 启动项目
```shell
$ ./bin/www #启动服务
```

#### 使用 [pm2][3] 管理

```json
// 1. 修改 ./docs/process.json 文件
{
    "apps" : [
        {
            "name"      : "code-push-server",
            "max_memory_restart" : "300M",
            "script"    : "../bin/www", //path/to/www
            "instances"  : "max", //开启实例数量，max为cpu核数
            "exec_mode"  : "cluster", //集群模式，最大提升网站并发
            "env" : {
                "NODE_ENV" : "production",
                "PORT" : 3000,
                "CONFIG_FILE" : "../config/config.js" // /path/to/config.js
            }
        }
    ]
}

// 2. 安装 pm2
$ npm install pm2 -g
$ pm2 start path/to/process.json

// 3. 更多 pm2 命令
$ pm2 stop [options] <id|name|all|json|stdin...>  关闭服务
$ pm2 list 查看所有
$ pm2 show <id> 查看某个服务的信息
```

此时热更新服务器已经部署完成，接下来介绍 APP 内集成方式以及发布和管理更新的常用命令。

## APP 集成

### 安装 [react-native-code-push][2]

```shell
$ npm install react-native-code-push@latest --save
```

### iOS

#### 修改 plist 配置文件

```xml
key: CodePushServerURL value: CodePush 服务地址
key: CodePushDeploymentKey value: CodePushKey

eg: 
<key>CodePushServerURL</key>
<string>http://192.168.1.3:3000/</string>
<key>CodePushDeploymentKey</key>
<string>aE8BkGLYt9TIThA1gobiJjzfcflZ4ksvOXqog</string>
```

#### 配置启动路径 jsCodeLocation

```objective-c
NSURL *jsCodeLocation = [CodePush bundleURL];
RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:moduleName
                                                 initialProperties:properties
                                                     launchOptions:launchOptions];
```

### Android

```java
private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {

	@Override
    protected String getJSBundleFile() {
        //这里修改 JSBundleFile 路径
        return CodePush.getJSBundleFile();
    }

    @Override
    protected boolean getUseDeveloperSupport() {
        return BuildConfig.DEBUG;
    }
    
	@Override
	protected List<ReactPackage> getPackages() {
		return Arrays.<ReactPackage>asList(
			new CodePush(
				"aE8BkGLYt9TIThA1gobiJjzfcflZ4ksvOXqog", 应用的deploymentKey
				getApplicationContext(),
				BuildConfig.DEBUG,
				"http://192.168.1.3:3000" //服务器地址
			)
		);
	}
	
  	@Override
  	public ReactNativeHost getReactNativeHost() {
      	return mReactNativeHost;
  	}
}
```

### JS

```js
import CodePush from "react-native-code-push";

...

componentDidMount() {
    // deploymentKey: 部署key，指定你要查询更新的部署秘钥，默认情况下该值来自于 Info.plist(Ios) 和 MainActivity.java(Android) 文件，你可以通过设置该属性来动态查询不同部署 key 下的更新。
    // installMode (codePush.InstallMode): 安装模式，用在向CodePush推送更新时没有设置强制更新( mandatory 为 true)的情况下，默认 codePush.InstallMode.ON_NEXT_RESTART 即下一次启动的时候安装。
    // mandatoryInstallMode (codePush.InstallMode): 强制更新，默认 codePush.InstallMode.IMMEDIATE。
    // minimumBackgroundDuration (Number): 该属性用于指定app处于后台多少秒才进行重启已完成更新，默认为0。该属性只在 installMode 为 InstallMode.ON_NEXT_RESUME 情况下有效。
    // updateDialog (UpdateDialogOptions): 可选的，更新的对话框，默认是null，包含以下属性 {
    //      appendReleaseDescription (Boolean) - 是否显示更新description，默认false
    //      descriptionPrefix (String) - 更新说明的前缀。 默认是” Description: “
    //      mandatoryContinueButtonLabel (String) - 强制更新的按钮文字. 默认 to “Continue”.
    //      mandatoryUpdateMessage (String) - 强制更新时，更新通知. Defaults to “An update is available that must be installed.”.
    //      optionalIgnoreButtonLabel (String) - 非强制更新时，取消按钮文字. Defaults to “Ignore”.
    //      optionalInstallButtonLabel (String) - 非强制更新时，确认文字. Defaults to “Install”.
    //      optionalUpdateMessage (String) - 非强制更新时，更新通知. Defaults to “An update is available. Would you like to install it?”.
    //      title (String) - 要显示的更新通知的标题. Defaults to “Update available”.
    //}
    CodePush.sync();
}
 
...
```

## 配置与管理应用

### 安装 code-push-cli

```shell
$ npm install -g code-push-cli
// 修改密码命令行
$ curl -X PATCH -H "Authorization: Bearer mJxbwjODns2IlrWRvrOGLIDWbHut4ksvOXqog" -H "Accept: application/json" -H "Content-Type:application/json" -d '{"oldPassword":"123456","newPassword":"654321"}' http://192.168.1.3:3000/users/password
```
### 登录服务器

```shell
// 登录，使用命令行后会打开网页，服务器地址请填写实际地址，登录后获取 token ，然后把获取到的 token 值复制到命令行中。
$ code-push login http://192.168.1.3:3000
A browser is being launched to authenticate your account. Follow the instructions it displays to complete your login.
 
// 填写获取到的 Authentication key
Enter your access key:  mJxbwjODns2IlrWRvrOGLIDWbHut4ksvOXqog
//Enter your access key:  dp6hUimLgeBBrWfvz8wAQh4Y4izB4ksvOXqog 正式的access key
Successfully logged-in. Your session file was written to /Users/oeffect/.code-push.config. You can run the code-push logout command at any time to delete this file and terminate your session.
```

### 常用命令行

```shell
// 备注:OS是安卓就是 Android
$ code-push app add ksd_courier-ios ios react-native
 
Successfully added the "ksd_courier-ios" app, along with the following default deployments:
┌────────────┬───────────────────────────────────────┐
│ Name       │ Deployment Key                        │
├────────────┼───────────────────────────────────────┤
│ Production │ yYoA5qatsqgmr7NDq105USYkUYK74ksvOXqog │
├────────────┼───────────────────────────────────────┤
│ Staging    │ a688maXloQT2vPqjU0laqeBjtJUt4ksvOXqog │
└────────────┴───────────────────────────────────────┘
 
// 查看所有APP
$ code-push app list
┌─────────────────┬──────────────────────┐
│ Name            │ Deployments          │
├─────────────────┼──────────────────────┤
│ ksd_courier-ios │ Production, Staging  │
└─────────────────┴──────────────────────┘
 
// 添加自定义环境
$ code-push deployment add ksd_courier-ios Developer
Successfully added the "Developer" deployment with key "aE8BkGLYt9TIThA1gobiJjzfcflZ4ksvOXqog" to the "ksd_courier-ios" app.
 
// 查看 APP 所有环境
$ code-push deployment list ksd_courier-ios --format json
[
  {
    "createdTime": 1479924559000,
    "id": "1",
    "key": "yYoA5qatsqgmr7NDq105USYkUYK74ksvOXqog",
    "name": "Production",
    "package": null
  },
  {
    "createdTime": 1479924559000,
    "id": "4",
    "key": "a688maXloQT2vPqjU0laqeBjtJUt4ksvOXqog",
    "name": "Staging",
    "package": null
  }
]
 
// 更多查看 APP 信息的命令行
$ code-push deployment history ksd_courier-ios Production
$ code-push deployment add <appName> 部署
$ code-push deployment rename <appName> 重命名
$ code-push deployment rm <appName> <deploymentNmae> 删除部署
$ code-push deployment ls <appName> 列出应用的部署情况
$ code-push deployment ls <appName> -k 查看部署的key
$ code-push deployment history <appName> <deploymentNmae> 查看历史版本 
$ code-push deployment clear <appName> <deploymentNmae> 清除历史部署记录
 
 
// 打包 JS 文件和资源命令
$ react-native bundle <command>
 
--entry-file //ios或android入口的文件名称，一般叫 index.ios.js或 index.android.js
--platform //平台名称(ios/android)
--dev //设置为false的时候会对JavaScript代码进行优化处理。
--bundle-output //生成的jsbundle文件的名称(包含路径)，比如./ios/bundle/index.ios.jsbundle
--assets-dest //图片以及其他资源存放的目录,比如./ios/assets
 
e.g. :
$ react-native bundle --platform ios --entry-file index.ios.js --bundle-output ./ios/bundle/index.ios.jsbundle --dev false
$ react-native bundle --platform android --entry-file index.android.js --bundle-output ./android/bundles/index.android.bundle --dev false
 
// 发布命令（打包文件并上传到服务器）
$ code-push release-react <appName> <OS> <updateContents> <deploymentNmae> <description> <disabled> <mandatory>
<appName> //必须 app名称
<OS> //必须 发布平台iOS/Android
<updateContents> //非必须 Bundle文件所在目录
<targetBinaryVersion> //非必须 需要热更的app 版本
<deploymentNmae> //必须 需要发布的部署
<description> //非必须 描述 (更新客户端不可见必须有"hide"  eg: --description "hide xxxx")
<disabled> //非必须 该版本客户端是否可以获得更新,默认为false
<mandatory> //非必须  如果有则表示app强制更新
e.g. :
$ code-push release-react ksd_courier-ios ios --plistFile ./ios/ksudi_courier_rn/Info.plist -d Test --description "描述"  --disabled true --m true
```

[0]: http://microsoft.github.io/code-push/
[1]: https://github.com/lisong/code-push-server
[2]: https://github.com/Microsoft/react-native-code-push
[3]: http://pm2.keymetrics.io
[4]: http://update.reactnative.cn/home

