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
