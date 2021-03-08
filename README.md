# ubunut-with-sshd

基于 ubuntu:20.04 加上 sshd 和一些常用的开发工具，建议搭配
使用 vscode 装 ms-vscode-remote.remote-ssh 插件一起用.
通常可以一个项目一个容器实例，开发环境独立互不干扰.

NOTE: 开发工具因为每个项目需求各异，就不整合了.

+ 用户密码 ubuntu/Pa$$w0rd$
+ 时区默认用UTC，如果要修改请重配tzdata，语言编码用 en_US.UTF-8 要改请重配 locales 即可。

## 编译发布

```shell
docker build -f Dockerfile -t hexiaoyuan/ubunut-with-sshd:latest .
docker tag hexiaoyuan/ubunut-with-sshd:latest hexiaoyuan/ubunut-with-sshd:v20200308
docker push hexiaoyuan/ubunut-with-sshd -a
```

## 本地开启一个容器实例

```shell
docker pull hexiaoyuan/ubunut-with-sshd
docker run -d --init --privileged --restart=always -p 60101:22 --name mydev01 --hostname mydev01 hexiaoyuan/ubunut-with-sshd
```

## 进入

```shell
docker exec -it mydev01 bash

### 进入后先把默认密码修改掉(ubuntu/Pa$$w0rd$):
ubuntu@mydev01:~$:~$ passwd
Changing password for ubuntu.
Current password:
New password:
Retype new password:

### 把预设的key更新一下:
$ ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519

### 把自己登陆要用的的key加入：
$ vi /home/ubuntu/.ssh/authorized_keys

### 根据自己需求调整bash的配置
$ vi ~/.bashrc

### 退出
$ exit

```

## 远程访问

```shell
## 用ssh连接试试，注意端口和ip地址:
ssh ubuntu@127.0.0.1 -p 60101 

## 在macos上建议用iterm2+tmux来访问:
ssh ubuntu@127.0.0.1 -p 60101 -t tmux -CC new -A -s main
```

## 如果在国内，建议修改apt源为国内阿里

修改 /etc/apt/sources.list

```txt
deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
```

## 使用 volume 来保存数据(建议)

```shell
docker volume create vol_home_mydev01
docker volume inspect vol_home_mydev01

docker run -d --init --privileged -p 60101:22 --name mydev01 --hostname mydev01 \
  --mount source=vol_home_mydev01,target=/home  \
  --restart=always --memory="4g" --cpus=2 hexiaoyuan/ubunut-with-sshd:20200308

docker exec -it mydev01 bash

```
