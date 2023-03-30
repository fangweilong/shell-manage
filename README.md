# 注意点

申请jetbrains开发者License

## 说明

    目前只在centos7.x系列测试过

## docker

### docker官方下载地址

    自行下载需要的版本。

[点我进入docker下载页](https://download.docker.com/linux/centos/7/x86_64/stable/Packages/)

离线安装需要下载*docker-ce*、*docker-ce-cli*、*containerd.io*、 *docker-buildx-plugin*、*docker-compose-plugin* 、*docker-ce-rootless-extras*

### 上传到服务器

    推荐上传到 /home/docker 下，但要注意保持目录结构不变

## nginx

    nginx建议到官方的地址下载

### nginx官方下载地址

[点我进入下载页](http://nginx.org/packages/centos/7/x86_64/RPMS/)

## 执行

    centos系列：sh main.sh
    debian系列：bash main.sh
    其他的根据脚本提示操作
