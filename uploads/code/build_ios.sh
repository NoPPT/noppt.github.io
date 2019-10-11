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