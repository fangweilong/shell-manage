#!/bin/bash
#nginx管理

#清除屏幕的代码，防止命令太多
clear

#step1 前言
echo -e "\033[33m Author:   $author	Date:     $updateDate	Version:  $version \033[0m"
echo "注意事项："
echo "============================================================"
echo "	1.离线安装请查看readme中说明，自行下载对应版本的离线包并放置到 offline-file/nginx/ 下"
echo "============================================================"

flag=12344

# 获取到当前工作目录。是以main.sh为基准
DIR=$(cd $(dirname $0) && pwd )

nginxFilePath=$DIR/shell/offline-file/nginx

#主方法
readnum(){
	while [ "$flag" -ne 0 ]
	do
		#目前支持的命令
		echo

		echo -e "\033[34m 	Nginx \033[0m"
		echo -e "\033[33m 		1.重启nginx \033[0m"
		echo -e "\033[33m 		2.启动nginx \033[0m"
		echo -e "\033[33m 		3.停止nginx \033[0m"
		echo -e "\033[33m 		4.离线安装nginx \033[0m"
		echo -e "\033[33m 		5.开机启动nginx \033[0m"
		echo -e "\033[33m 		6.开机禁止启动nginx \033[0m"
        echo -e "\033[33m 		7.nginx版本 \033[0m"
        echo -e "\033[33m 		8.nginx状态 \033[0m"
        echo -e "\033[33m 		9.卸载nginx \033[0m"

        echo -e "\033[34m 	111111.退出  \033[0m"
		echo -e ""
		echo -e "\033[35m 请输入数字：  \033[0m"
		#读取用户输入
		read num

		#判断用户输入
		case $num in
		   	#Nginx相关
			1)
			restartNginx
			 ;;
			2)
			startNginx
			 ;;
			3)
			stopNginx
			 ;;
			4)
			offlineInstallNginx
			 ;;
			5)
			enableNginx
			 ;;
			6)
			disableNginx
			 ;;
            7)
			nginxVersion
			 ;;
            8)
			nginxStatus
			 ;;
            9)
			nginxRemove
			 ;;

			#退出
		    111111)
			flag=0
			echo "退出============================================================"
		        ;;
		    *)
		    echo "请输入一个正确的数字"
		esac

	done
}

#离线安装Nginx
offlineInstallNginx(){
	echo -e '\n检查是否已经安装Nginx:'
	nginx -v
    if [ $? -eq 0 ];then
        echo -e '\nnginx已安装'
        return 0;
    else
        read -p '请输入完整的rpm包名（仅文件名，注意文件路径要按照脚本规定的路径）:' FILENAME
        searchFile $nginxFilePath/$FILENAME
        if [ $? -eq 1 ];then
            echo -e '\n文件不存在'
            return 1;
        fi

        echo -e '\n赋予执行权限'
        chmod +x $nginxFilePath/$FILENAME

        yum install -y $nginxFilePath/$FILENAME

        nginx -v
        if [ $? -eq 0 ];then
            echo -e '\nnginx安装成功'
            return 0;
        else
            return 1;
        fi
    fi
}



#启动nginx
startNginx(){
	systemctl start nginx
	if [ $? -ne 0 ];then
		echo -e '\n启动失败'
		return 1;
    fi
	echo -e '\n启动成功'
	return 0;
}

#停止Nginx
stopNginx(){
	systemctl stop nginx
	if [ $? -ne 0 ];then
		echo -e '\n停止失败'
		return 1;
    fi
	echo -e '\n停止成功'
	return 0;
}

#开机启动Nginx
enableNginx(){
	systemctl enable nginx
	if [ $? -ne 0 ];then
		echo -e '\n配置失败'
		return 1;
    fi
	echo -e '\n配置成功'
	return 0;
}

#禁止开机启动Nginx
disableNginx(){
	systemctl disable nginx
	if [ $? -ne 0 ];then
		echo -e '\n配置失败'
		return 1;
    fi
	echo -e '\n配置成功'
	return 0;
}

#重启Nginx
restartNginx(){
	systemctl disable nginx
	if [ $? -ne 0 ];then
		echo -e '\n重启失败'
		return 1;
    fi
	echo -e '\n重启成功'
	return 0;
}

#nginx版本
nginxVersion(){
	nginx -v
	if [ $? -ne 0 ];then
		echo -e '\nnginx不存在或未启动'
		return 1;
    fi
	return 0;
}

#nginx状态
nginxStatus(){
	systemctl status nginx
	echo $?
	if [ $? -ne 0 ];then
		echo -e '\nnginx不存在或未启动'
		return 1;
    fi
	return 0;
}

# 卸载nginx
nginxRemove(){
    nginxStatus

    if [ $? -ne 0 ];then
        echo -e '\nnginx未安装，不需要卸载'
		return 1;
    fi

    echo -e '\n未确保误触进行nginx移除操作，请输入以下随机数字'
    RandomNum="`date +%s |cksum |cut -d " " -f 1`%100" |bc;
    echo -e $RandomNum
    read -p '请输入:' confirm
    if [ $RandomNum -ne confirm ];then
        echo -e '输入错误,退出删除操作'
        return 1;
    fi

    yum remove -y nginx

    if [ $? -ne 0 ];then
		echo -e '\nnginx移除失败'
		return 1;
    fi
    echo -e '\nnginx移除成功。将再次检查nginx'
    nginxStatus
    if [ $? -eq 1 ];then
		return 1;
    fi
    return 0;
}

readnum


