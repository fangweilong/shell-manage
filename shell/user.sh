#!/bin/bash
# 用户管理

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

		echo -e "\033[34m 	用户 \033[0m"
		echo -e "\033[33m 		1.添加用户 \033[0m"
		echo -e "\033[33m 		2.修改用户密码 \033[0m"
		echo -e "\033[33m 		3.添加用户组 \033[0m"
		echo -e "\033[33m 		4.为用户添加用户组 \033[0m"

		echo -e "\033[34m 	111111.退出  \033[0m"
		echo -e ""
		echo -e "\033[35m 请输入数字：  \033[0m"
		#读取用户输入
		read num

		#判断用户输入
		case $num in
			1)
		    addUser
		    ;;
			2)
		    updatePassword
		    ;;
			3)
		    addGroup
		    ;;
			4)
		    addGroupForUser
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

#添加用户
addUser(){
	read -p '请输入用户名:' USERNAME

	checkUserExist $USERNAME
	if [ $? -eq 0 ];then
        echo -e '用户已存在，请检查用户名'
        return 1;
    fi

	# 添加用户并创建同名用户组
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

	checkUserExist $USERNAME
	if [ $? -eq 1 ];then
        echo -e '用户不存在，请检查用户名'
        return 1;
    fi

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

readnum


