# codeinit.sh
# 这个是通用的步骤,所以写在一个单据文件里面，方便执行
yarn cache clean
yarn install
yarn upgrade
git status
git checkout .
git status
