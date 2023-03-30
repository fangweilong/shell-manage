#!/bin/bash
#docker管理

#清除屏幕的代码，防止命令太多
clear

#step1 前言
echo -e "\033[33m Author:   $author	Date:     $updateDate	Version:  $version \033[0m"
echo "注意事项："
echo "============================================================"
echo "	1.在线安装使用docker官方脚本，安装失败会尝试使用daoCloud脚本安装"
echo "	2.离线安装请查看readme中说明，自行下载对应版本的离线包并放置到 offline-file/docker/ 下"
echo "============================================================"

flag=12344

# 获取到当前工作目录。是以main.sh为基准
DIR=$(cd $(dirname $0) && pwd )

dockerFilePath=$DIR/shell/offline-file/docker

#主方法
readnum(){
	while [ "$flag" -ne 0 ]
	do
		#目前支持的命令
		echo

		echo -e "\033[34m 	Docker \033[0m"
		echo -e "\033[33m 		1.重启docker \033[0m"
		echo -e "\033[33m 		2.启动docker \033[0m"
		echo -e "\033[33m 		3.停止docker \033[0m"
		echo -e "\033[33m 		10.在线安装(升级)docker \033[0m"
		echo -e "\033[33m 		20.离线安装docker \033[0m"
		echo -e "\033[33m 		21.离线更新docker \033[0m"
		echo -e "\033[33m 		30.开机启动docker \033[0m"
		echo -e "\033[33m 		31.开机禁止启动docker \033[0m"
		echo -e "\033[33m 		100.删除docker \033[0m"
		echo -e "\033[33m 		101.删除老版本docker \033[0m"

		echo -e "\033[34m 	111111.退出  \033[0m"
		echo -e ""
		echo -e "\033[35m 请输入数字：  \033[0m"
		#读取用户输入
		read num

		#判断用户输入
		case $num in
		   	#docker相关
			1)
			restartDocker
			 ;;
			2)
			startDocker
			 ;;
			3)
			stopDocker
			 ;;
			10)
			onlineInstallDocker
			 ;;
			11)
			onlineUpgradeDocker
			 ;;
			20)
			offlineInstallDocker
			 ;;
			21)
			offlineUpgradeDocker
			 ;;
			30)
			enableDocker
			 ;;
			31)
			disableDocker
			 ;;
			100)
			removeDocker
			 ;;
			 101)
			removeOldDocker
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

#在线安装(升级)docker
onlineInstallDocker(){
	echo -e '\n检查是否已经安装docker'
	docker -v

	if [ $? -eq 0 ];then
		echo -e '\ndocker已安装'
	else
		#检查是否有yum-utils
		yum info installed yum-utils
		if [ $? -ne 0 ];then
			echo -e '\n缺失yum-utils，正在安装中...'
			yum -y install yum-utils

			if [ $? -eq 0 ];then
				echo -e '\nyum-utils安装成功'
			else
				echo -e '\nyum-utils安装失败，请检查'
				return 1;
			fi
		fi

		# 更新存储库
		sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

		echo -e '\n开始安装docker...'
		echo -e '\n请输入需要安装的docker版本。如果是最新稳定版请直接回车'
		echo -e '\ndocker版本：'
		read dockerVersion

		if [ ${#dockerVersion} -eq 0 ];then
			echo -e '\n即将开始安装最新正式版docker，请等待...'
			sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
		else
			echo -e '\n您指定了安装 $dockerVersion 版本的docker'
			echo -e '\n即将开始安装docker，请等待...'
			sudo yum install docker-ce-$dockerVersion docker-ce-cli-$dockerVersion containerd.io docker-buildx-plugin docker-compose-plugin
			if [ $? -eq 0 ];then
				echo -e '\n安装成功'
				echo -e '\ndocker版本：'
				docker -v

				echo -e '\ndocker compose版本：'
				docker compose version
			else
				echo -e '\ndocker安装失败，请检查后重试'
				return 1;
			fi
		fi
	fi
	return 0;
}

#离线安装docker
offlineInstallDocker(){
	echo -e '\n检查是否已经安装docker:'
	yum info installed docker

	if [ $? -eq 0 ];then
		echo -e '\ndocker已安装'
	else

		sudo yum install $dockerFilePath/*.rpm

		if [ $? -eq 0 ];then
			echo -e '\n安装成功'

			cp $dockerFilePath/docker.service /etc/systemd/system/
			if [ $? -eq 0 ];then
				echo -e '\ndocker.service复制成功'
			else
				echo -e '\ndocker.service复制失败'
			fi

			cp $dockerFilePath/docker.sock /etc/systemd/system/

			if [ $? -eq 0 ];then
				echo -e '\ndocker.sock复制成功'
			else
				echo -e '\ndocker.sock复制失败'
			fi

			sudo systemctl daemon-reload
		else
			echo -e '\n安装失败'
			return 1;
		fi
	fi

    return 0
}

#离线升级docker
offlineUpgradeDocker(){
	echo -e '\ndocker升级前的版本为:'
	yum info installed docker

	if [ $? -eq 0 ];then
		echo -e '\n升级前关闭docker，防止出现问题'
		echo -e '\n关闭中.....'
		sudo systemctl stop docker

		echo -e '\n升级中，请等待...'
		sudo yum upgrade $dockerFilePath/*.rpm

	else
		echo -e '\ndocker未安装，请检查后重试或直接离线安装docker'
		return 1;
	fi

    return 0
}

#启动docker
startDocker(){
	systemctl start docker
	if [ $? -ne 0 ];then
		echo -e '\n启动失败'
		return 1;
    fi
	echo -e '\n启动成功'
	return 0;
}

#停止docker
stopDocker(){
	systemctl stop docker
	if [ $? -ne 0 ];then
		echo -e '\n停止失败'
		return 1;
    fi
	echo -e '\n停止成功'
	return 0;
}

#开机启动docker
enableDocker(){
	sudo systemctl enable docker.service

	if [ $? -ne 0 ];then
		echo -e '\n配置失败'
		return 1;
    fi
	echo -e '\n配置成功'
	return 0;
}

#禁止开机启动docker
disableDocker(){
	sudo systemctl disable docker.service

	if [ $? -ne 0 ];then
		echo -e '\n配置失败'
		return 1;
    fi
	echo -e '\n配置成功'
	return 0;
}

#重启docker
restartDocker(){
	systemctl disable docker
	if [ $? -ne 1 ];then
		echo -e '\n重启失败'
		return 1;
    fi
	echo -e '\n重启成功'
	return 0;
}

#删除docker
removeDocker(){
	echo -e '\n卸载docker。注意：不会删除镜像、容器、卷、网络等数据，只删除docker本体'
	sudo yum remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
	return 0;
}


#删除老版本的docker
removeOldDocker(){
	echo -e '\n先卸载docker。注意：不会删除镜像、容器、卷、网络等数据，只删除docker本体'
	sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

	return 0;
}

readnum


