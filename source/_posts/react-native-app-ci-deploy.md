---
title: React Native 项目使用 Jenkins 持续集成部署步骤
date: 2018-03-03 11:14:16
tags:
    - CI
    - Jenkins
    - React Native
categories: React Native
---

App 开发过程中总是需要打包诸多版本提供测试部分进行测试，由于我们的 App 是使用 React Native 进行开发的，每次更新又分为热更新和安装包更新，如果每次都通过命令行进行热更新或者在本机上进行编译打包的话十分影响自己的工作效率。所以搭建一套持续集成环境把这些重复工作自动化就变的十分必要的了，持续集成的好处相信大家都了解了很多，只是搭建步骤比较繁琐，这里就把我之前使用 [Jenkins][0] 搭建持续集成环境的过程总结下来，留作参考。
<!-- more -->

开始之前总结一下哪些功能需要解决的一些问题：
- 代码依赖问题。由于 Android 原生项目中会依赖一些三方库，所以在构建 Android 项目前，需要先执行用于下载依赖库的 Job。
- 热更新。由于需要热更新时并不需要重新构建原生安装包，所以把热更新当做一个单独的Job，这一部分主要是更新代码并执行热更新命令行。
- Android 打包。这里把 Android 打包当做一个单独的 Job，为了满足自动化构建需要对原生项目做一些改进，包括三方库的依赖路径，以及一些构建参数，需要改成能接受外部传入参数。其余的可根据实际情况定制参数，比如我们项目同一份代码，需要分为三个不同的 logo，以及不同的接口地址进行分发，这时需要使用多渠道打包，所以我们的 Jenkins 也要根据情况传入自定义的参数。
- iOS 打包。同样的 iOS 打包也是一个单独的 Job，iOS 项目没有直接接受外部传入参数的方法，这里我们可以在构建过程中，根据 Jenkins 参数，进行手动修改 plist 文件内的属性达到自定义属性的效果。同时配合在同一 workspace 下创建不同的 target 和 scheme 达到区分安装包的效果。
- 构建通知。由于打包需要消耗不少的时间，实时盯着进度显然不合适。所以我们需要在 Job 执行结束时发送邮件通知相关人员。

综上所述，要实现以上的需求，直接使用 Jenkins 里面提供的打包插件实现起来并不方便。所以我这里把一些主要的操作都通过执行 shell 脚本实现。

## 依赖环境

```
Jenkins 2.89.2
macOS 10.13.2
Xcode 9.2
Gradle 2.14
```

## Jenkins 基础配置

### 安装依赖插件

> 路径：Jenkins => 系统管理 => 插件管理 => 可选插件 中搜索以下组件

- GitLab Plugin
- Email Extension Plugin
- Gradle Plugin
- Keychains and Provisioning Profiles Plugin

### 配置插件

#### Gradle Plugin
> 路径：Jenkins => 系统管理 => 全局工具配置 => Gradle

设置 gradle 版本，并设置对应的路径，这里使用 [2.14.1][1] 版本，一开始使用 3.0 以上版本在打包中报错 `GC overhead limit exceeded`，由于项目使用的就是 2.14.1 版本，为了方便就不更新项目 Gradle 版本了。

![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/gradle_config.png_blog)

#### Keychains and Provisioning Profiles Plugin
> 路径：Jenkins => 系统管理 => Keychains and Provisioning Profiles Management

![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/keychains_provisioning_profiles.png_blog)
这里需要上传两种类型的文件 .keychain 和 .mobileprovision

##### 上传 .keychain 文件

1. 打开钥匙串访问，找到系统中已安装过证书的 .keychain 文件。一般为登录钥匙串下，系统中的文件位置为 /Users/username/Library/Keychains/login.keychain（系统在 10.12 以上可能由于升级系统找不到 login.keychain 文件，只有 login.keychain-db 文件，由于上传 .keychain-db 格式的会失败，此时可以复制 login.keychain-db 文件后重命名为 login.keychain 用于上传）。
![图1](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/keychains_cers.png_blog)
2. 上传成功后，如图1，在黄框2中输入密码，一般为当前用户登录密码。 
3. 点击黄框3中的 Add Code Signing Identity 按钮，在 Identities 中添加证书对应的标识，可以在钥匙串中查看常用名称,右键证书，点击显示简介: 
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/cer_detail.png_blog)

##### 上传 .mobileprovision 文件

1. 设置 Provisionging Profiles Directory Path。主要用于存储上传的 .mobileprovision 文件, 一般为默认路径即可，如图1-黄框4
1. 上传 .mobileprovision 文件。上传后可以看到如图1-黄框5，即代表上传成功

##### Email Extension Plugin
相较与默认提供的邮箱通知，Email Extension Plugin 提供的功能更强大 
1. Default Recipients，配置默认的收件人
1. Default Subject，配置默认的邮件标题
1. Default Content，配置默认的邮件内容等
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/email_1.png_blog)
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/email_2.png_blog)
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/email_3.png_blog)

##### 保存配置

#### 配置系统设置
> 路径：Jenkins => 系统管理 => 系统设置

##### 配置全局属性
> 路径：Jenkins => 系统管理 => 系统设置 => 全局属性

键 | 值
---|---
PATH | 通过 shell 命令 echo PATH 获取系统 PATH 的路径
ANDROID_HOME | 设置 ANDROID_HOME， 如果项目中包含 local.properties 文件，可以不用设置，一般情况下 local.properties 会忽略上传到 git

![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/global_environment.png_blog)

##### 配置邮件通知

![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/email_server.png_blog)

## 热更新

### 创建 job
> 路径：Jenkins => 新建
选择`构建一个自由风格的软件项目`，并输入任务名称，然后点确认。
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/add_job.png_blog)

### 源码管理

![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/source_manager.png_blog)

这里使用 git 管理代码，输入文件仓库路径，设置 Credentials，设置要构建的分支 Branches to build，这里我设置的是 `*/${BRANCH}`，为了偷懒我就不重新截图了，同样的源码管理这一步在后续的 Android 以及 iOS 构建也需要添加，不过步骤相同，后续也不重复了，- -！。

### 参数化构建

需要自定义的参数要根据实际情况添加，不必要完全相同，我这里把我设置的都记录下来了。

<style>
table th:nth-of-type(1) {
    width: 80px;
}
table th:nth-of-type(2) {
    width: 170px;
}
table th:nth-of-type(4) {
    width: 100px;
}
</style>

类型 | 名字 | 默认值 | 描述
--- | --- | --- | ---
Choice Parameter | BRANCH | develop<br/>master | 代码分支
Boolean Parameter | CODE_PUSH | false | 是否热更新此次推送
Choice Parameter | CODE_PUSH_TEST_ENV | test<br/>master |推送服务器环境
Choice Parameter | CODE_PUSH_DEPLOY | all<br/>ksd_shuttle<br/>ksd_shuttle_ems<br/>ksd_shuttle_sgr | 推送哪些APP
Choice Parameter | CODE_PUSH_PLATFORM | all<br/>android<br/>ios | 推送更新的设备类型
String Parameter | CODE_PUSH_DESC | | 推送内容信息
Boolean Parameter | CODE_PUSH_MAN | false | 是否强制更新

### 构建

![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/xcodebuild_shell.png_blog)

根据具体情况执行一些初始化命令
```shell
# codeinit.sh
# 这个是通用的步骤,所以写在一个单据文件里面，方便执行
yarn cache clean
yarn install
yarn upgrade
git status
git checkout .
git status
```
```shell
# codepush.sh

# 根据参数判断要热更新的环境，这里主要是写一个判断然后执行相应的命令行就好了
if [[ $CODE_PUSH = true ]]; then
    echo "=================code push start================="
	if [[ $CODE_PUSH_TEST_ENV = 'test' ]]; then
        codepushUrl="http://192.168.1.14:3000"
        codepushKey=""
    elif  [[ $CODE_PUSH_TEST_ENV = 'master' ]]; then
        codepushUrl="http://master.com:3200"
        codepushKey=""
    else
        codepushUrl="http://192.168.1.14:3000"
        codepushKey=""
    fi
    echo "codepushUrl: " ${codepushUrl}
    echo "codepushKey: " ${codepushKey}

    code-push logout
    echo ${codepushKey} | code-push login ${codepushUrl}
	code-push app list
    
    if [[ $CODE_PUSH_PLATFORM = 'all' ]]; then
        if [[ $CODE_PUSH_DEPLOY = 'all' ]]; then 
        else
        code-push release-react ${CODE_PUSH_DEPLOY}-ios ios --plistFile ./ios/ksudi_courier_rn/Info.plist -d Production --description "${CODE_PUSH_DESC}" --mandatory ${CODE_PUSH_MAN} --disabled true
        code-push release-react ${CODE_PUSH_DEPLOY}-android android -d Production --description "${CODE_PUSH_DESC}" --mandatory ${CODE_PUSH_MAN} --disabled true
        fi
    elif [[ $CODE_PUSH_PLATFORM = 'android' ]]; then
        if [[ $CODE_PUSH_DEPLOY = 'all' ]]; then 
        else
        code-push release-react ${CODE_PUSH_DEPLOY}-android android -d Production --description "${CODE_PUSH_DESC}" --mandatory ${CODE_PUSH_MAN} --disabled true
        fi
    else
        if [[ $CODE_PUSH_DEPLOY = 'all' ]]; then 
        else
        code-push release-react ${CODE_PUSH_DEPLOY}-ios ios --plistFile ./ios/ksudi_courier_rn/Info.plist -d Production --description "${CODE_PUSH_DESC}" --mandatory ${CODE_PUSH_MAN} --disabled true
        fi
    fi
    echo "=================code push success================="
    exit 0
else
    echo "=================update code success, does not code push================="
fi
```

### 构建后操作
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/after_source_job.png_blog)
可以通过设置构建后的操作，来实现不同的依赖关系，如当前项目依赖其他项目，可以在其他项目构建成功后执行当前项目（根据实际情况添加，这里有一点不是很满意的就是没法传入参数到后续项目）。

## 构建 Android 安装包

### 创建 job
选择`构建一个自由风格的软件项目`，并输入任务名称，然后点确认。这里要创建两个，由于 Android 项目依赖的有其他三方库，所以要根据实际情况创建对应的下载代码的 Job。

### 参数化构建

类型 | 名字 | 默认值 | 描述
--- | --- | --- | ---
Choice Parameter | BUILD_TYPE | Release<br/>Debug | 构建环境
Choice Parameter | PRODUCT_TYPE | Ksd<br/>Ems<br/>Sgr | 安装包类型
String Parameter | APP_VERSION | 1.0.0 | 安装包版本号（跟随代码设置）
String Parameter | APP_BUILD | 1 | 安装包构建号（跟随代码设置）
String Parameter | APK_PATH | ${WORKSPACE}/apk/ | 安装包输出路径
Extensible Choice | BUILD_TIME | return [new Date().format('yyyyMMdd')] | 构建时间
String Parameter | APK_NAME | ksd_shuttle_${BUILD_TIME}.apk | 安装包名
Boolean Parameter | JENKINS_BUILD | true | 是否为Jenkins打包

### 构建

#### Execute shell
```shell
sh codeinit.sh
```

#### Invoke Gradle script

1. Invoke Gradle 选中刚才添加的 2.14.1 版本
1. Use Gradle Wrapper 不需要选中，但是要配置信息
1. 配置 Task 内容 `clean assemble${PRODUCT_TYPE}Release --stacktrace --info --debug`
1. 如果项目路径不在当前 workspace，则设置 Root Build script 到对应项目的 build.gradle 文件所在的文件夹
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/android_build.png_blog)

#### Execute shell
```shell
# build_android.sh
# 主要是把安装包上传到内网发布平台，可以根据情况上传至蒲公英或者 fir 等平台
if [[ ${PRODUCT_TYPE} = 'Ksd' ]]; then
    if [[ ${IS_TEST_CODEPUSH} = true ]]; then
        APP_PLAT_ID=3
    else
        APP_PLAT_ID=4
    fi
elif [[ ${PRODUCT_TYPE} = 'Ems' ]]; then
    if [[ ${IS_TEST_CODEPUSH} = true ]]; then
        APP_PLAT_ID=7
    else
        APP_PLAT_ID=8
    fi
elif [[ ${PRODUCT_TYPE} = 'Sgr' ]]; then
    if [[ ${IS_TEST_CODEPUSH} = true ]]; then
        APP_PLAT_ID=11
    else
        APP_PLAT_ID=12
    fi
fi

curl --form plat_id=${APP_PLAT_ID} --form file_nick_name=${APK_NAME} --form token=b83ccaaa9dcef62d2d28cb030bc805fda2f1b03c --form file=@${APK_PATH}/${APK_NAME} https://192.168.1.38/api/pkgs
```

## 构建 iOS 安装包

### 创建 job
选择`构建一个自由风格的软件项目`，并输入任务名称，然后点确认。

### 参数化构建

类型 | 名字 | 默认值 | 描述
--- | --- | --- | ---
String Parameter | APP_NAME | ksudi_courier_rn | .xcworkspace 文件对应的文件名
Choice Parameter | SCHEME | ksd_shuttle<br/>ksd_shuttle_ems<br/>ksd_shuttle_sgr | 构建APP
String Parameter | PROJECT_PATH | ${WORKSPACE}/../ksudi-courier-rn/ios | .xcworkspace文件对应的文件夹路径
String Parameter | IPA_PATH | ${WORKSPACE}/ipa | ipa 包存放路径
String Parameter | ARCHIVE_PATH | ${WORKSPACE}/archive | .archive 文件存放路径
Choice Parameter | EXPORT_METHOD | enterprise<br/>development<br/>ad-hoc<br/>app-store | 导出安装包的类型
String Parameter | BUNDLE_IDENTIFIER | com.company.bundleid | 唯一标识
String Parameter | TEAM_ID | | 证书对应的TeamID（图三-组织单位） 

### 构建环境

1. 选中当前项目对应的签名证书
1. 选中当前项目对应的 provisioning profile 文件
1. Variable Prefix 根据 Code Signing Identity 和 provisioning profile 对应的安装包信息添加 DIS 或 DEV 前缀

![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/keychain_config.png_blog)

### 构建

增加构建步骤，选中 Execute shell，并配置如下，执行 shell 文件或直接把 shell 命令赋值到 Command 中

![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/xcodebuild_shell.png_blog)

```shell
sh codeinit.sh
```
```shell
# build_ios.sh
echo "=================app info================="
PLIST_PATH="${PROJECT_PATH}/${APP_NAME}/Info.plist"
echo "PLIST_PATH:" ${PLIST_PATH}
#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${PLIST_PATH}")
echo "bundleShortVersion:" ${bundleShortVersion}
#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${PLIST_PATH}")
echo "bundleVersion:" ${bundleVersion}
#bundle id
bundleId=${BUNDLE_IDENTIFIER}
echo "bundleId:" ${bundleId}

# 根据不同环境设置不同的安装包上传地址，以及不同的证书文件。
if [[ ${EXPORT_METHOD} = 'enterprise' || ${EXPORT_METHOD} = 'app-store' ]]; then
    PROVISIONING_PROFILE=${DIS_PROVISIONING_PROFILE}
    CODE_SIGNING_IDENTITY=${DIS_CODE_SIGNING_IDENTITY}
    KEYCHAIN_PASSWORD=${DIS_KEYCHAIN_PASSWORD}
    KEYCHAIN_PATH=${DIS_KEYCHAIN_PATH}
    BUILD_CONFIG='Release'
    if [[ ${SCHEME} = 'ksd_shuttle_ems' ]]; then
        APP_PLAT_ID=6
    elif [[ ${SCHEME} = 'ksd_shuttle' ]]; then
        APP_PLAT_ID=2
    elif [[ ${SCHEME} = 'ksd_shuttle_sgr' ]]; then
        APP_PLAT_ID=10
    fi
elif [ ${EXPORT_METHOD} = 'ad-hoc' ]; then 
    PROVISIONING_PROFILE=${DIS_PROVISIONING_PROFILE}
    CODE_SIGNING_IDENTITY=${DIS_CODE_SIGNING_IDENTITY}
    KEYCHAIN_PASSWORD=${DIS_KEYCHAIN_PASSWORD}
    KEYCHAIN_PATH=${DIS_KEYCHAIN_PATH}
    BUILD_CONFIG='Release'
    if [[ ${SCHEME} = 'ksd_shuttle_ems' ]]; then
        APP_PLAT_ID=5
    elif [[ ${SCHEME} = 'ksd_shuttle' ]]; then
        APP_PLAT_ID=1
    elif [[ ${SCHEME} = 'ksd_shuttle_sgr' ]]; then
        APP_PLAT_ID=9
    fi
else
    PROVISIONING_PROFILE=${DEV_PROVISIONING_PROFILE}
    CODE_SIGNING_IDENTITY=${DEV_CODE_SIGNING_IDENTITY}
    KEYCHAIN_PASSWORD=${DEV_KEYCHAIN_PASSWORD}
    KEYCHAIN_PATH=${DEV_KEYCHAIN_PATH}
    BUILD_CONFIG='Debug'
    if [[ ${SCHEME} = 'ksd_shuttle_ems' ]]; then
        APP_PLAT_ID=5
    elif [[ ${SCHEME} = 'ksd_shuttle' ]]; then
        APP_PLAT_ID=1
    elif [[ ${SCHEME} = 'ksd_shuttle_sgr' ]]; then
        APP_PLAT_ID=9
    fi
fi

# 配置打包是需要的 plist 文件，
EXPORT_PLIST_TEMPLATE="<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>compileBitcode</key><false/><key>method</key><string>${EXPORT_METHOD}</string><key>provisioningProfiles</key><dict><key>${bundleId}</key><string>${PROVISIONING_PROFILE}</string></dict><key>signingStyle</key><string>manual</string><key>stripSwiftSymbols</key><true/><key>teamID</key><string>${TEAM_ID}</string><key>thinning</key><string>&lt;none&gt;</string></dict></plist>"
echo "=================export info================="
EXPORT_PLIST_PATH="${WORKSPACE}/ExportOptions.plist"
echo "EXPORT_PLIST_TEMPLATE:" ${EXPORT_PLIST_TEMPLATE}
echo ${EXPORT_PLIST_TEMPLATE} > ${EXPORT_PLIST_PATH}

DATE="$(date +%Y%m%d)"
echo "DATE:" ${DATE}
echo "IPA_PATH:" ${IPA_PATH}
echo "ARCHIVE_PATH:" ${ARCHIVE_PATH}
ARCHIVE_FILE_PATH="${ARCHIVE_PATH}/${APP_NAME}.xcarchive"
echo "ARCHIVE_FILE_PATH:" ${ARCHIVE_FILE_PATH}

export LANG=en_US.UTF-8
echo "=================unlock keychain================="
/usr/bin/security list-keychains -s ${KEYCHAIN_PATH}
/usr/bin/security default-keychain -d user -s ${KEYCHAIN_PATH}
# 解锁 keychain
/usr/bin/security unlock-keychain -p ${KEYCHAIN_PASSWORD} ${KEYCHAIN_PATH} 
/usr/bin/security set-keychain-settings -t 3600 -l ${KEYCHAIN_PATH}
/usr/bin/security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k ${KEYCHAIN_PASSWORD} ${KEYCHAIN_PATH}
# /usr/bin/security set-key-partition-list -S apple-tool:,apple: -s -k ${KEYCHAIN_PASSWORD} ${KEYCHAIN_PATH}
/usr/bin/security show-keychain-info ${KEYCHAIN_PATH}
/usr/bin/security find-identity -p codesigning -v

echo "=================update pods================="
cd ${PROJECT_PATH}
pod update --no-repo-update

echo "=================xcodebuild command start================="
chmod -R 777 ${PROJECT_PATH}/../node_modules/react-native
xcodebuild -version
xcodebuild -showsdks

echo "=================list================="
xcodebuild -list -workspace "${PROJECT_PATH}/${APP_NAME}.xcworkspace"

echo "=================clean================="
xcodebuild -workspace "${PROJECT_PATH}/${APP_NAME}.xcworkspace" -scheme "${SCHEME}" -configuration "${BUILD_CONFIG}" clean

echo "=================archive================="
xcodebuild archive -workspace "${PROJECT_PATH}/${APP_NAME}.xcworkspace" -scheme "${SCHEME}" -sdk iphoneos -configuration "${BUILD_CONFIG}" -archivePath "${ARCHIVE_FILE_PATH}" CODE_SIGN_IDENTITY="${CODE_SIGNING_IDENTITY}" PROVISIONING_PROFILE="${PROVISIONING_PROFILE}"
if [ $? -eq 0 ]; then
    echo "=================archive success================="
else
    echo "=================archive failure================="
    exit 1
fi

echo "=================export================="
xcodebuild -exportArchive -archivePath "${ARCHIVE_FILE_PATH}" -exportPath "${IPA_PATH}" -exportOptionsPlist "${EXPORT_PLIST_PATH}"
if [ $? -eq 0 ]; then
    echo "=================export success================="
else
    echo "=================export failure================="
    exit 1
fi

echo "=================rename ipa================="
IPANAME="${SCHEME}_V${bundleShortVersion}_${DATE}.ipa"
echo "IPANAME:" ${IPANAME}
mv "${IPA_PATH}/${SCHEME}.ipa" "${IPA_PATH}/${IPANAME}" 
if [ $? -eq 0 ]; then
    echo "=================rename success================="
else
    echo "=================rename failure================="
    exit 1
fi

# 上传安装包到内网发布平台
curl --form plat_id=${APP_PLAT_ID} --form file_nick_name=${IPANAME} --form token=b83ccaaa9dcef62d2d28cb030bc805fda2f1b03c --form file=@${IPA_PATH}/${IPANAME} https://192.168.1.38/api/pkgs
```

### 更多
如果 archive 过程报如下错误，是因为每次签名都需要权限，没有找到通过命令行解决的办法，解决方法是用 Xcode 打开项目并打包，在最后会提示 是否允许 codesign 获取钥匙串权限 点击始终允许，然后就不会出如下错误了。或者如脚本中设置权限，并在钥匙串中双击密钥，然后修改访问控制为允许所有应用程序访问项目。

![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/change_key_info.png_blog)

```
# 遇到的错误信息
/usr/bin/codesign --force --sign BECCC467849A21A6C3090FF3913F38BE5C25171A --entitlements /Users/ksudi/Library/Developer/Xcode/DerivedData/ksudi_courier_rn-ghscruhcynnsgeaxehveiqyurbpm/Build/Intermediates.noindex/ArchiveIntermediates/ksd_shuttle/IntermediateBuildFilesPath/ksudi_courier_rn.build/Release-iphoneos/ksd_shuttle.build/ksd_shuttle.app.xcent --timestamp=none /Users/ksudi/Library/Developer/Xcode/DerivedData/ksudi_courier_rn-ghscruhcynnsgeaxehveiqyurbpm/Build/Intermediates.noindex/ArchiveIntermediates/ksd_shuttle/InstallationBuildProductsLocation/Applications/ksd_shuttle.app
/Users/ksudi/Library/Developer/Xcode/DerivedData/ksudi_courier_rn-ghscruhcynnsgeaxehveiqyurbpm/Build/Intermediates.noindex/ArchiveIntermediates/ksd_shuttle/InstallationBuildProductsLocation/Applications/ksd_shuttle.app: unknown error -1=ffffffffffffffff
Command /usr/bin/codesign failed with exit code 1

** ARCHIVE FAILED **
```

## 配置构建成功后操作

### 邮件通知模板

这里主要使用 HTML 写邮件模板，需要根据不同 Job 定义不同的模板，这里提供一个参考。
```html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>${ENV, var="JOB_NAME"}-第${BUILD_NUMBER}次构建日志</title>
</head>

<body leftmargin="8" marginwidth="0" topmargin="8" marginheight="4"
    offset="0">
    <table width="95%" cellpadding="0" cellspacing="0"
        style="font-size: 11pt; font-family: Tahoma, Arial, Helvetica, sans-serif">
        <tr>
            <td><br />
            <b><font color="#0B610B">构建信息</font></b>
            <hr size="2" width="100%" align="center" /></td>
        </tr>
        <tr>
            <td>
                <ul>
                    <li>项目名称：${PROJECT_NAME}</li>
                    <li>构建编号：第${BUILD_NUMBER}次构建</li>
                    <li>APP 名称：${APP_NAME}</li>
                    <li>APP 标识：${BUNDLE_IDENTIFIER}</li>
                    <li>安装包类型：${EXPORT_METHOD}</li>
                    <li>构建日志：<a href="${BUILD_URL}console">${BUILD_URL}console</a></li>
                    <li>构建 Url：<a href="${BUILD_URL}">${BUILD_URL}</a></li>
                    <li>项目 Url：<a href="${PROJECT_URL}">${PROJECT_URL}</a></li>
                </ul>
            </td>
        </tr>
        <tr>
            <td><b><font color="#0B610B">变更集</font></b>
            <hr size="2" width="100%" align="center" /></td>
        </tr>
        <tr>
            <td>${JELLY_SCRIPT,template="html"}<br/>
            <hr size="2" width="100%" align="center" /></td>
        </tr>
    </table>
</body>
</html>
```

### 添加 Editable Email Notification

如果需要发送邮件的构建 job，则在构建后操作中添加 Editable Email Notification
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/after_build.png_blog)

### 配置基础信息

- 如果需要发送附件和 attach build log 在这里选中，默认是不发送
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/attach_info.png_blog)
- Triggers 中配置接受者信息，默认是 Developers 需要自己添加配置的 Recipient List，根据自己实际情况而定 
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/triggers.png_blog)
- Triggers 中默认的响应构建状态为在插件中配置的信息，如果需要自定义，点击 Add Trigger 添加需要的构建状态
![img](http://p4wb4s2l1.bkt.clouddn.com/image/blog/1/add_triggers.png_blog)

## 结束

感谢大家能够一路看下来，以上就是我在搭建持续部署环境时主要的一些步骤，写的比较乱，可能会有一些步骤写的比较简单，可能对于一些项目这样搭建起来过于麻烦，不过对于我们公司的项目是目前我能想到的相对简单可行的方法了。希望对大家能起到一点帮助~~~

[0]: https://jenkins.io/
[1]: https://downloads.gradle.org/distributions/gradle-2.14.1-all.zip