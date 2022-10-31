#!/bin/bash

# 节点所在路径 以/结尾
serverPath=/data/web/
# 节点文件夹名 不以/结尾
nodePath=web-front

# 编译好后的文件地址 以/结尾
buildPath=/data/deploy/
# 编译后的文件夹名 不以/结尾
buildName=build-web

# 备份的文件夹名 不以/结尾
backup=backup;
# 备份的日期 不以/结尾
backupFolder=$(date +%F);
# 备份的文件夹规则名（具体的文件夹名，不以/结尾）
backupFileName=$(date +%F-%s);


# 备份操作
back(){
  cd $serverPath$nodePath

  # 检查备份文件是否存在
  if [ -e $backup/$backupFolder ]; then
    echo -e "---$backup/$backupFolder备份文件夹存在，进入下一步---"
  else
    echo -e "---$backup/$backupFolder 备份文件夹不存在，创建文件夹---"
    mkdir $backup/$backupFolder
  fi

  tar -jcvf $backupFileName.tar.gz webapps/$nodePath/
  mv $backupFileName.tar.gz $backup/$backupFolder/
}

# 部署
deploy(){
  if [ -e $serverPath$nodePath ]; then
    echo -e "---$serverPath$nodePath 文件夹存在，进入下一步---"
    rm -rf $serverPath$nodePath/*
  else
    echo -e "---$serverPath$nodePath 文件夹不存在，创建文件夹---"
    mkdir $serverPath$nodePath
  fi
  cp -r $buildPath$buildName/* $serverPath$nodePath/

}




exit 0
