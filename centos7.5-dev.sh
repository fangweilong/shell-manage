#!/bin/bash
#step1 前言 
echo "注意事项：建议新建新用户 需要有sudo权限"
echo -e "\033[33m Author:   Teler	Date:     2019/10/05	Version:  1.0 \033[0m"

flag=12344

#主方法
readnum(){
	while [ "$flag" -ne 0 ]
	do
		#目前支持的命令 
		echo
		echo -e "\033[35m 请查看需要执行的命令的对应数字 \033[0m"
		echo -e "\033[34m 	服务器 \033[0m"
		echo -e "\033[33m 		1.获取本机ip \033[0m"
		
		echo -e "\033[34m 	用户 \033[0m"		
		echo -e "\033[33m 		2.添加用户 \033[0m"
		echo -e "\033[33m 		3.修改用户密码 \033[0m"
		echo -e "\033[33m 		4.添加用户组 \033[0m"
		echo -e "\033[33m 		5.为用户添加用户组 \033[0m"
		
		echo -e "\033[34m 	防火墙  \033[0m"
		echo -e "\033[33m 		100.查询防火墙状态  \033[0m"
		echo -e "\033[33m 		101.本次关闭防火墙  \033[0m"
		echo -e "\033[33m 		102.本次开启防火墙  \033[0m"
		echo -e "\033[33m 		103.开机启动防火墙  \033[0m"
		echo -e "\033[33m 		104.开机禁止启动防火墙  \033[0m"
		
		echo -e "\033[34m 	Docker \033[0m"		
		echo -e "\033[33m 		200.重启docker \033[0m"
		echo -e "\033[33m 		201.启动docker \033[0m"
		echo -e "\033[33m 		202.停止docker \033[0m"
		echo -e "\033[33m 		203.在线安装docker(包括docker-compose) \033[0m"
		echo -e "\033[33m 		204.离线安装docker(包括docker-compose) \033[0m"
		echo -e "\033[33m 		205.开机启动docker \033[0m"
		echo -e "\033[33m 		206.开机禁止启动docker \033[0m"


		echo -e "\033[34m 	系统 \033[0m"		
		echo -e "\033[33m 		900.重启 \033[0m"
		echo -e "\033[33m 		901.关机 \033[0m"
		
		echo -e "\033[34m 	111111.退出  \033[0m"
		echo -e ""
		echo -e "\033[35m 请输入数字：  \033[0m"
		#读取用户输入
		read num

		#判断用户输入
		case $num in
		    1)
		    getIp
		     ;;
			2)
		    addUser
		    ;;
			3)
		    updatePassword
		    ;;
			4)
		    addGroup
		    ;;
			5)
		    addGroupForUser
		    ;;			

			# 防火墙相关
		    100)
			firewalldStatus
			 ;;
		    101)
			firewalldStop
			 ;;
		    102)
			firewalldStart
			 ;;
		    103)
			firewalldDisable
			 ;;
		    104)
			firewalldEnable
			 ;;
		   	#docker相关 	
			200)
			restartDocker
			 ;;		 
			201)
			startDocker
			 ;;
			202)
			stopDocker
			 ;;
			203)
			onlineInstallDocker
			 ;;
			204)
			offlineInstallDocker
			 ;;
			205)
			enableDocker
			 ;;
			206)
			disableDocker
			 ;;
			900)
			restartNow
			 ;;
			901)
			shutdownNow
			 ;;

			#退出
		    111111)
			echo "感谢使用"
			flag=0
		        ;;
		    *)
		    echo "请输入一个正确的数字"
		esac

	done
		exit
}
	
#获取ip
getIp(){
	echo -e "\033[33m IP地址：  \033[0m"
	ip addr
	if [ $? -ne 0 ];then
        echo -e '\n查询失败'
        return 1;
    fi	
	return 0;
}

#添加用户
addUser(){
	read -p '请输入用户名:' USERNAME

	adduser -g $USERNAME $USERNAME
	if [ $? -ne 0 ];then
        echo -e '\n添加失败'
        return 1;
    fi

	passwd $USERNAME
	if [ $? -ne 0 ];then
        echo -e '\n修改失败'
        return 1;
    fi

	return 0;
}	

#修改用户密码
updatePassword(){
	read -p '请输入用户名:' USERNAME
	passwd $USERNAME
	if [ $? -ne 0 ];then
        echo -e '\n修改失败'
        return 1;
    fi	
	return 0;
}


#添加用户组
addGroup(){
	read -p '请输入用户组:' USERGROUP
	groupadd $USERGROUP
	if [ $? -ne 0 ];then
        echo -e '\n添加失败'
        return 1;
    fi	
	return 0;
}



#为用户添加用户组
addGroupForUser(){
	read -p '请输入用户组:' USERGROUP

	read -p '请输入用户名:' USERNAME
	usermod -G $USERGROUP $USERNAME
	if [ $? -ne 0 ];then
        echo -e '\n添加失败'
        return 1;
    fi	
	return 0;
}


#防火墙状态
firewalldStatus(){
	systemctl status firewalld.service
	if [ $? -ne 0 ];then
        echo -e '\n查询失败'
        return 1;
    fi	
	return 0;
}

#本次关闭防火墙
firewalldStop(){
	systemctl stop firewalld.service
	if [ $? -ne 0 ];then
        echo -e '\n关闭失败'
        return 1;
    fi	
	return 0;
}

#本次开启防火墙
firewalldStart(){
	systemctl start firewalld.service
	if [ $? -ne 0 ];then
        echo -e '\n开启失败'
        return 1;
    fi	
	return 0;
}

#禁止防火墙开机自启
firewalldDisable(){
	systemctl disable firewalld.service
	if [ $? -ne 0 ];then
        echo -e '\n配置失败'
        return 1;
    fi	
	return 0;
}

#禁止防火墙开机自启
firewalldEnable(){
	systemctl enable firewalld.service
	if [ $? -ne 0 ];then
        echo -e '\n配置失败'
        return 1;
    fi	
	return 0;
}

#在线安装docker
onlineInstallDocker(){
	# step 1: 安装相关组件和配置yum源
	sudo yum install -y yum-utils \
	  device-mapper-persistent-data \
	  lvm2
	if [ $? -ne 0 ];then
        echo -e '\n安装失败'
        return 1;
    fi
	
	sudo yum-config-manager \
		--add-repo \
		http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
	if [ $? -ne 0 ];then
            echo -e '\n设置失败'
            return 1;
    fi	
	# step 2: 配置缓存
	sudo yum makecache fast
	if [ $? -ne 0 ];then
        echo -e '\n设置失败'
        return 1;
    fi
	# step 3: 执行安装
	sudo yum install docker-ce
	if [ $? -ne 0 ];then
        echo -e '\n安装失败'
        return 1;
    fi
	echo -e '\ndocker版本：'
    docker -v

	systemctl daemon-reload
	
	echo -e '\n安装docker-compose：'
	sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	if [ $? -ne 0 ];then
        echo -e '\n安装失败'
        return 1;
    fi

	echo -e '\n为docker-compose赋权：'
	sudo chmod +x /usr/local/bin/docker-compose
	if [ $? -ne 0 ];then
        echo -e '\n赋权成功'
        return 1;
    fi

	echo -e '\ndocker-compose版本：'
	docker-compose --version



	return 0;
}

#离线安装docker
offlineInstallDocker(){
	echo -e '\n请将docker-ce压缩包、docker-compose压缩包、docker.server上传到与本文件同一路径下'

	echo -e '\n检查是否已经安装docker:'
	docker -v

	if [ $? -eq 0 ];then
		echo -e '\ndocker已安装,检查docker-compose'
		#调用离线安装docker-compose
		installDockerCompose

		return 0;
	else
		read -p '请输入完整的docker压缩包文件名（仅包名）:' FILENAME

		searchFile docker/$FILENAME
		if [ $? -ne 0 ];then
			echo -e '\n文件不存在'
			return 1;
		fi

		echo -e '\n解压文件...'

		tar -xzvf docker/$FILENAME -C docker/
		if [ $? -eq 0 ];then
			echo -e '\n将docker目录移到/usr/bin目录下...'
			cp docker/docker/* /usr/bin/
			if [ $? -ne 0 ];then
				echo -e '\n复制失败'
				return 1;
			fi
			echo -e '\n将docker.service 移到/etc/systemd/system/ 目录...'
			searchFile docker/docker.service
			if [ $? -ne 0 ];then
				echo -e '\n文件不存在'
				return 1
			fi
			cp docker/docker.service /etc/systemd/system/
			if [ $? -eq 0 ];then
				echo -e '\n添加文件权限...'
				chmod +x /etc/systemd/system/docker.service
				if [ $? -ne 0 ];then
					echo -e '\n添加失败'
					return 1;
				fi
				echo -e '\n重新加载配置文件...'
				systemctl daemon-reload
				if [ $? -ne 0 ];then
					echo -e '\n加载失败'
					return 1;
				fi
				echo -e '\n启动docker...'
				systemctl start docker
				if [ $? -ne 0 ];then
					echo -e '\n启动失败'
					return 1;
				fi
				echo -e '\n设置开机自启...'
				systemctl enable docker.service
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
		return 0;
	else
		#安装docker-compose
		read -p '请输入完整的docker-compose压缩包文件名（仅包名）:' DOCKERCOMPOSEFILENAME
		searchFile docker/$DOCKERCOMPOSEFILENAME
		if [ $? -ne 0 ];then
			echo -e '\n文件不存在'
			return 1;
		fi
		echo -e '\n复制文件到/usr/local/bin下 并重命名为docker-compose'
		cp docker/$DOCKERCOMPOSEFILENAME /usr/local/bin/docker-compose
		if [ $? -eq 0 ];then
			echo -e '\n赋予执行权限'
			chmod +x /usr/local/bin/docker-compose
			if [ $? -ne 0 ];then
				echo -e '\n赋予权限失败'
				return 1;
			fi

			echo -e '\ndocker-compose版本：'
			docker-compose -v
			if [ $? -eq 0 ];then
				echo -e '\ndocker-compose安装成功'
			fi
		else 
			echo -e '\n复制失败'
			return 1;
		fi
	fi
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
	systemctl enable docker
	if [ $? -ne 0 ];then
		echo -e '\n配置失败'
		return 1;
    fi	
	echo -e '\n配置成功'
	return 0;
}

#禁止开机启动docker
disableDocker(){
	systemctl disable docker
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
	if [ $? -ne 0 ];then
		echo -e '\n重启失败'
		return 1;
    fi	
	echo -e '\n重启成功'
	return 0;
}

#重启
restartNow(){
	echo -e '\n即将重启，请输入 0 确认操作，否则请随意输入：'
	read -p '' CONFIRM 
	if [ $CONFIRM -eq 0 ];then
		reboot
	else 
		echo -e '\n终止了操作'
	fi
	return 0
}

#关机
shutdownNow(){
	echo -e '\n即将关机，请输入 0 确认操作，否则请随意输入：'
	read -p '' CONFIRM 
	if [ $CONFIRM -eq 0 ];then
		halt
	else 
		echo -e '\n终止了操作'
	fi
	return 0
}


#检查文件是否存在
#存在返回0 不存在返回1
function searchFile(){
    if [ -f "$1" ]; then
        return 0
    else 
        return 1
    fi
}


readnum


