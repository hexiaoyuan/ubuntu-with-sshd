# 开发容器实例开启后的进一步设置

## 针对开发

### 修改apt源并更新

sed -i 's#http://mirrors.aliyun.com/ubuntu/#mirror://mirrors.ubuntu.com/mirrors.txt#' /etc/apt/sources.list
sudo apt update
sudo apt dist-upgrade

### 安装docker

sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ubuntu

### 手工启动docker服务

sudo /etc/init.d/docker start

如果想重启docker是自动启动docker,可以把上面行加到 ~/.local/auto.sh 文件中去.
建议需要时开启即可，用完关掉省点资源.

### 安装aws工具

sudo apt --no-install-recommends install awscli
aws s3 ls

### 安装golang环境 (选择手动安装)

wget https://golang.org/dl/go1.16.linux-amd64.tar.gz
rm -rf ~/.local/go && tar -C ~/.local/ -xzf go1.16.linux-amd64.tar.gz
vi $HOME/.profile
```
export PATH=$PATH:$HOME/.local/go/bin:$HOME/go/bin
```
$ go version
$ go env

### 安装nodejs环境(选择手动安装)

NODEJS_VERSION=v14.16.0
wget https://nodejs.org/dist/$NODEJS_VERSION/node-$NODEJS_VERSION-linux-x64.tar.xz
tar -C ~/.local -xJvf node-$NODEJS_VERSION-linux-x64.tar.xz
cd ~/.local;
rm -f nodejs; ln -s node-$NODEJS_VERSION-linux-x64 nodejs; cd -;
vi $HOME/.profile
```
export PATH=$PATH:$HOME/.local/nodejs/bin
```
$ node -v
$ npm version
$ npx -v

