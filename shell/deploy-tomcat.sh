#!/bin/bash

:<<!
  tomcat部署war项目的快捷脚本
  注意各种文件夹的路径配置
!

# 节点所在路径 路径最后带斜杠
servicePath=/data/web/;
# 节点文件夹名
nodePath=tomcat-8080;
# 要部署的jar所在路径 路径最后带斜杠
jarPath="/home/tomcat/test/";
# 要部署的war文件名(没有扩展名)-数组
warName=(test1 test2)

# 节点的完整路径
nodeFullPath="$servicePath$nodePath";
# 备份的文件夹名
backup=backup;
# 备份的日期
backupFolder=$(date +%F);
# 备份的文件夹规则名（具体的文件夹名）
backupFileName=$(date +%F-%s);
# 关闭成功的检测间隔（秒）
checkInterval=5

# 备份操作
back(){
  # 检查备份文件是否存在
  if [ -e $backup/$backupFolder ]; then
    echo -e "---$backup/$backupFolder备份文件夹存在，进入下一步---"
  else
    echo -e "---$backup/$backupFolder 备份文件夹不存在，创建文件夹---"
    mkdir $backup/$backupFolder
  fi

  # 打包并压缩备份 conf、webapps bin
  tar -jcvf $backupFileName.tar.gz webapps/ bin/ conf/
  mv $backupFileName.tar.gz $backup/$backupFolder/
}

# 对war进行操作
war(){
  cd $nodeFullPath/webapps
  for ele in ${warName[@]}; do
    echo "---删除原本的war包 ${ele}.war---"
    rm -rf $ele.war
    echo "---从 ${jarPath} 复制war包 ${ele}.war---"
    cp $jarPath$ele.war .
  done
  cd ../
}

# 操作tomcat
tomcatStop(){
  echo "---停止tomcat---"
  sh $nodeFullPath/bin/catalina.sh stop
  # 循环10次，每3秒检查一次是否正常关闭
  for ((i=0; i<10; i++)); do
    pid=`ps -ef | grep ${nodeFullPath} | grep -v "grep" | awk '{print $2}'`
    if [ -z $pid ]; then
      echo -e '----------'$i': '$nodePath' 停止成功----------'
      break
    else
      echo -e '----------'$i': proc '$pid' 存在....----------'

    if [ $i'x' == '4x'  ]; then
      echo -e '----------第'$i'次失败，尝试kill '$pid'----------'
      kill $pid
    fi
      sleep $checkInterval
    fi
  done

  # 等待结束，仍未正常关闭，就强制kill
  pid=`ps -ef | grep $nodeFullPath | grep -v "grep" | awk '{print $2}'`
  if [ $pid'x' != 'x'  ]; then
    echo -e "----------强制停止进程 ${pid}----------"
    kill -9 $pid
  fi

  cd $nodeFullPath/webapps
  for ele in ${warName[@]}; do
    echo -e "---准备删除webapps下的${ele}---"
    rm -rf $ele
  done
  cd ../

  return 0
}

tomcatStart(){
  echo "---启动tomcat---"
  sh $nodeFullPath/bin/catalina.sh start
}


echo "---tomcat工作目录 ${nodeFullPath}---"

echo -e "---检查节点文件夹是否存在 ${nodeFullPath}---"
if [ -e $nodeFullPath ]; then
  echo -e "---节点文件夹存在，进入节点文件夹---\n"
  cd $nodeFullPath
  echo -e "-"
else
  echo -e "---节点文件夹不存在，请检查---\n"
  exit 1
fi

tomcatStop

back

war

tomcatStart

exit 0
