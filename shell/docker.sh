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
		echo -e "\033[33m 		4.在线安装docker(包括docker-compose) \033[0m"
		echo -e "\033[33m 		5.离线安装docker(包括docker-compose) \033[0m"
		echo -e "\033[33m 		6.开机启动docker \033[0m"
		echo -e "\033[33m 		7.开机禁止启动docker \033[0m"

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
			4)
			onlineInstallDocker
			 ;;
			5)
			offlineInstallDocker
			 ;;
			6)
			enableDocker
			 ;;
			7)
			disableDocker
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
		# setp 1: 执行在线安装脚本
		sudo curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun

		if [ $? -eq 1 ];then
			echo -e '\n使用Aliyun安装失败,尝试使用daoCloud安装...'
			sudo curl -sSL https://get.daocloud.io/docker | sh
			if [ $? -eq 1 ];then
				echo -e '\n使用daoCloud安装失败'
				return 1;
			fi
		fi
		echo -e '\ndocker版本：'

		docker -v
		# 重新加载
		systemctl daemon-reload

	fi

	echo -e '\n检查是否已经安装docker-compose:'
	docker-compose -v

	if [ $? -eq 0 ];then
		echo -e '\ndocker-compose已经安装'
	else
		echo -e '\n安装docker-compose：'
		sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		if [ $? -eq 1 ];then
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
		if [ $? -eq 1 ];then
			return 1
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

		echo -e '\n解压文件...'

		tar -xzvf $dockerFilePath/$FILENAME -C $dockerFilePath/
		if [ $? -eq 0 ];then
			echo -e '\n将docker目录移到/usr/bin目录下...'
			cp $dockerFilePath/docker/* /usr/bin/
			if [ $? -eq 1 ];then
				echo -e '\n复制失败'
				return 1;
			fi
			echo -e '\n将docker.service 移到/etc/systemd/system/ 目录...'
			searchFile $dockerFilePath/docker.service
			if [ $? -eq 1 ];then
				echo -e '\n文件不存在'
				return 1
			fi
			cp $dockerFilePath/docker.service /etc/systemd/system/
			if [ $? -eq 0 ];then
				echo -e '\n为docker.service添加文件权限...'
				chmod +x /etc/systemd/system/docker.service
				if [ $? -eq 1 ];then
					echo -e '\n添加失败'
					return 1;
				fi
				echo -e '\n重新加载配置文件...'
				systemctl daemon-reload
				if [ $? -eq 1 ];then
					echo -e '\n加载失败'
					return 1;
				fi
				echo -e '\n启动docker...'
				systemctl start docker
				if [ $? -eq 1 ];then
					echo -e '\n启动失败'
					return 1;
				fi
				echo -e '\n设置开机自启...'
				systemctl enable docker.service
				if [ $? -eq 1 ];then
					echo -e '\n开机启动失败'
					return 1;
				fi
				echo -e '\ndocker版本：'
				docker -v
				if [ $? -eq 1 ];then
					echo -e '\n安装失败'
					return 1;
				else
					#调用离线安装docker-compose
					installDockerCompose
				fi
			else
				echo -e '\n复制失败'
				return 1;
			fi
		else
			echo -e '\n解压失败'
			return 1;
		fi
	fi

    return 0
}

#安装docker-compose
installDockerCompose(){
	echo -e '\n检查docker-compose是否安装：'
	docker-compose -v
	if [ $? -eq 0 ];then
		echo -e '\ndocker-compose已安装'
	else
		#安装docker-compose
		read -p '请输入完整的docker-compose压缩包文件名（仅文件名，注意文件路径要按照脚本规定的路径）:' DOCKERCOMPOSEFILENAME
		searchFile $dockerFilePath/$DOCKERCOMPOSEFILENAME
		if [ $? -eq 1 ];then
			echo -e '\n文件不存在'
			return 1;
		fi
		echo -e '\n复制文件到/usr/local/bin下 并重命名为docker-compose'
		cp $dockerFilePath/$DOCKERCOMPOSEFILENAME /usr/local/bin/docker-compose
		if [ $? -eq 0 ];then
			## 再次检查
			searchFile /usr/local/bin/docker-compose
			if [ $? -eq 0 ];then
				echo -e '\n为docker-compose赋予执行权限'
				chmod +x /usr/local/bin/docker-compose
				if [ $? -eq 1 ];then
					echo -e '\n赋予权限失败'
					return 1;
				fi

				echo -e '\ndocker-compose版本：'
				docker-compose -v
				if [ $? -eq 1 ];then
					echo -e '\ndocker-compose安装失败'
					return 1;
				fi
			else
				echo -e '\n复制失败'
				return 1;
			fi
		else
			echo -e '\n复制失败'
			return 1;
		fi
	fi

	return 0;
}


#启动docker
startDocker(){
	systemctl start docker
	if [ $? -eq 0 ];then
		echo -e '\n启动失败'
		return 1;
    fi
	echo -e '\n启动成功'
	return 0;
}

#停止docker
stopDocker(){
	systemctl stop docker
	if [ $? -eq 0 ];then
		echo -e '\n停止失败'
		return 1;
    fi
	echo -e '\n停止成功'
	return 0;
}

#开机启动docker
enableDocker(){
	systemctl enable docker
	if [ $? -eq 0 ];then
		echo -e '\n配置失败'
		return 1;
    fi
	echo -e '\n配置成功'
	return 0;
}

#禁止开机启动docker
disableDocker(){
	systemctl disable docker
	if [ $? -eq 0 ];then
		echo -e '\n配置失败'
		return 1;
    fi
	echo -e '\n配置成功'
	return 0;
}

#重启docker
restartDocker(){
	systemctl disable docker
	if [ $? -eq 1 ];then
		echo -e '\n重启失败'
		return 1;
    fi
	echo -e '\n重启成功'
	return 0;
}

readnum


