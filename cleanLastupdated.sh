# 这里写你的仓库路径
REPOSITORY_PATH=~/.m2/repository
echo 正在搜索...
find $REPOSITORY_PATH -name "*lastUpdated*" | xargs rm -rf
echo 搜索完
