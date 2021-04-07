#!/bin/bash
# 系统管理

#清除屏幕的代码，防止命令太多
clear

#step1 前言
echo -e "\033[33m Author:   $author	Date:     $updateDate	Version:  $version \033[0m"
echo "注意事项："
echo "============================================================"

echo "============================================================"

flag=12344

#主方法
readnum(){
	while [ "$flag" -ne 0 ]
	do
		#目前支持的命令
		echo

		echo -e "\033[34m 	主机管理 \033[0m"
		echo -e "\033[33m 		1.获取IP \033[0m"
		echo -e "\033[33m 		11.立即重启 \033[0m"
		echo -e "\033[33m 		12.立即关机 \033[0m"

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
			11)
		    restartNow
		     ;;
			12)
		    shutdownNow
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

readnum


