#!/bin/bash
# 防火墙管理

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

		echo -e "\033[34m 	防火墙 \033[0m"
		echo -e "\033[33m 		1.查询防火墙状态  \033[0m"
		echo -e "\033[33m 		2.本次关闭防火墙  \033[0m"
		echo -e "\033[33m 		3.本次开启防火墙  \033[0m"
		echo -e "\033[33m 		4.开机启动防火墙  \033[0m"
		echo -e "\033[33m 		5.开机禁止启动防火墙  \033[0m"

		echo -e "\033[34m 	111111.退出  \033[0m"
		echo -e ""
		echo -e "\033[35m 请输入数字：  \033[0m"
		#读取用户输入
		read num

		#判断用户输入
		case $num in
			# 防火墙相关
		    1)
			firewalldStatus
			 ;;
		    2)
			firewalldStop
			 ;;
		    3)
			firewalldStart
			 ;;
		    4)
			firewalldDisable
			 ;;
		    5)
			firewalldEnable
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

readnum


