#!/bin/bash

#清除屏幕的代码，防止命令太多
clear

#设置版本相关信息
author=Teler
version=1.1
updateDate=2021-04-06

echo -e "\033[33m Author:   $author	Date:     $updateDate	Version:  $version \033[0m"
echo "注意事项："
echo "============================================================"
echo "	1.建议新建有sudo权限的新用户"
echo "	2.脚本仅在centos7.x完整测试，docker、用户在debian系可以正常使用，防火墙等未完成测试"
echo "============================================================"

# 公共参数
flag=12344
# 脚本的路径
shPath=shell

#主方法
readnum(){
	while [ "$flag" -ne 111111 ]
	do
		#目前支持的命令
		echo
		echo -e "\033[35m 请查看需要执行的命令的对应数字 \033[0m"
		echo -e "\033[34m 	服务器 \033[0m"
		echo -e "\033[33m 		1.获取本机ip \033[0m"

		echo -e "\033[34m 	用户 \033[0m"
		echo -e "\033[33m 		2.用户管理 \033[0m"

		echo -e "\033[34m 	防火墙  \033[0m"
		echo -e "\033[33m 		3.防火墙管理  \033[0m"

		echo -e "\033[34m 	Docker \033[0m"
		echo -e "\033[33m 		4.docker相关 \033[0m"

		echo -e "\033[34m 	主机 \033[0m"
		echo -e "\033[33m 		5.主机管理 \033[0m"

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

			# 用户相关
			2)
		    userManage
			 ;;

			# 防火墙相关
		    3)
			firewalldManage
			 ;;

		   	#docker相关
			4)
			dockerManage
			;;

			# 主机管理
			5)
			computerManage
			 ;;

			#退出
		    111111)
			echo "感谢使用"
			flag=111111
		        ;;
		    *)
		    echo "请输入一个正确的数字"
		esac

	done
		exit
}



#添加用户
userManage(){
	source $shPath/user.sh
}


# 调用docker脚本
dockerManage(){
    source $shPath/docker.sh
}

# 调用防火墙脚本
firewalldManage(){
    source $shPath/firewalld.sh
}

# 调用主机管理
computerManage(){
    source $shPath/computer.sh
}



# 公共方法 开始====================================================

#检查文件是否存在 存在返回0 不存在返回1
function searchFile(){
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

#判断用户是否存在 存在返回0 不存在返回1
function checkUserExist(){
	id $1
	echo $?
	if [ $? -ne 0 ];then
        return 1;
    fi
	return 0;
}


# 公共方法 结束====================================================

readnum


