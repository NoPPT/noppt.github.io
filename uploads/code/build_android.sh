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