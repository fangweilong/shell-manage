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
		echo -e "\033[33m 		10.在线安装docker(包括docker-compose) \033[0m"
		echo -e "\033[33m 		11.在线升级docker(包括docker-compose) \033[0m"
		echo -e "\033[33m 		20.离线安装docker(包括docker-compose) \033[0m"
		echo -e "\033[33m 		21.离线更新docker(包括docker-compose) \033[0m"
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

#在线安装docker
onlineInstallDocker(){
	echo -e '\n检查是否已经安装docker'
	docker -v

	if [ $? -eq 0 ];then
		echo -e '\ndocker已安装'
	else
		echo -e '\n安装yum-utils'

		yum install -y yum-utils


		echo -e '\ndocker版本：'
		docker -v
	fi

	echo -e '\n检查是否已经安装docker-compose:'
	docker-compose -v

	if [ $? -eq 0 ];then
		echo -e '\ndocker-compose已经安装'
	else
		echo -e '\n请指定docker-compose版本： '
		# todo
		read docker-compose-version
		sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		if [ $? -ne 0 ];then
			echo -e '\n安装失败'
			return 1;
		fi

		echo -e '\n为docker-compose赋权：'
		sudo chmod +x /usr/local/bin/docker-compose
		if [ $? -eq 0 ];then
			echo -e '\n赋权成功'
			return 0;
		fi

		echo -e '\ndocker-compose版本：'
		docker-compose -v
		if [ $? -ne 0 ];then
			return 1
		fi
	fi
	return 0;
}

#在线升级docker
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
		echo -e '\n需要安装的docker指定版本（最新稳定版直接回车）：'

		read dockerVersion

		if [ ${#dockerVersion} -eq 0 ];then
			echo -e '\n即将开始安装最新正式版docker(包含docker-ce、docker-buildx、docker-compose)，请等待...'
			sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
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
	docker -v

	if [ $? -eq 0 ];then
		echo -e '\ndocker已安装,检查docker-compose'
		#调用离线安装docker-compose
		installDockerCompose
		if [ $? -eq 1 ];then
			return 1;
		fi
	else
		read -p '请输入完整的docker压缩包文件名（仅文件名，注意文件路径要按照脚本规定的路径）:' FILENAME

		searchFile $dockerFilePath/$FILENAME
		if [ $? -eq 1 ];then
			echo -e '\n文件不存在'
			return 1;
		fi

		echo -e '\n安装中，请等待...'

		sudo yum install $dockerFilePath/$FILENAME

		if [ $? -eq 0 ];then
				echo -e '\n安装成功，准备启动docker...'
				sudo systemctl start docker
				if [ $? -ne 0 ];then
					echo -e '\n启动失败'
					return 1;
				fi
				echo -e '\n设置docker开机自启...'
				sudo systemctl enable docker.service
				if [ $? -ne 0 ];then
					echo -e '\n开机启动失败'
					return 1;
				fi
				echo -e '\ndocker版本：'
				docker -v
				if [ $? -ne 0 ];then
					echo -e '\n安装失败'
					return 1;
				else
					#调用离线安装docker-compose
					installDockerCompose
				fi
		else
			echo -e '\ndocker安装失败'
			return 1;
		fi
	fi

    return 0
}

#离线升级docker
offlineUpgradeDocker(){
	echo -e '\ndocker升级前的版本为:'
	docker -v

	if [ $? -eq 0 ];then
		echo -e '\n升级前关闭docker，防止出现问题'
		echo -e '\n关闭中.....'
		sudo systemctl stop docker

		read -p '请输入完整的docker压缩包文件名（仅文件名，注意文件路径要按照脚本规定的路径）:' FILENAME
		searchFile $dockerFilePath/$FILENAME
		if [ $? -eq 1 ];then
			echo -e '\n文件不存在'
			return 1;
		fi

		echo -e '\n升级中，请等待...'

		sudo yum -y upgrade $dockerFilePath/$FILENAME

		if [ $? -eq 0 ];then
				echo -e '\n安装成功，准备启动docker...'
				sudo systemctl start docker
				if [ $? -ne 0 ];then
					echo -e '\n启动失败'
					return 1;
				fi
				echo -e '\n设置docker开机自启...'
				sudo systemctl enable docker.service
				if [ $? -ne 0 ];then
					echo -e '\n开机启动失败'
					return 1;
				fi
				echo -e '\ndocker升级后的版本：'
				docker -v
				if [ $? -ne 0 ];then
					echo -e '\n安装失败'
					return 1;
				else
					#调用离线安装docker-compose
					installDockerCompose
				fi
		else
			echo -e '\ndocker安装失败'
			return 1;
		fi
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
	sudo systemctl enable containerd.service

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
	sudo systemctl disable containerd.service

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
	echo -e '\n为确保不是误触进行docker移除操作，请输入以下随机数字'
    RandomNum="`date +%s |cksum |cut -d " " -f 1`%100" |bc;
    echo -e $RandomNum
    read -p '请输入:' confirm
    if [ $RandomNum -ne confirm ];then
        echo -e '输入错误,退出删除操作'
        return 1;
    fi

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


