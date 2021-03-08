#########
# ubuntu-20.04 with openssh-server and ...
#
# + git, vim, python3, tmux, curl, htop, elinks and other;
# x ohmyzsh;
# x Node.js LTS (v14.x) and yarn;
#
#########

# Build Ubuntu image with base functionality.
FROM ubuntu:20.04 AS ubuntu-base

#RUN sed -i 's#http://archive.ubuntu.com/ubuntu/#mirror://mirrors.ubuntu.com/mirrors.txt#' /etc/apt/sources.list;
RUN sed -i 's#archive.ubuntu.com#mirrors.aliyun.com#' /etc/apt/sources.list && sed -i 's#security.ubuntu.com#mirrors.aliyun.com#' /etc/apt/sources.list


ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install required tools: sshd,vim,python3...
RUN apt-get -qq update && apt-get -qq -y dist-upgrade  \
    && apt-get -y -qq --no-install-recommends install \
        apt-utils apt-transport-https ca-certificates software-properties-common curl \
    && apt-get -y -qq --no-install-recommends install \
        sudo vim openssh-server net-tools bind9-dnsutils \
        python3 build-essential git \
        gnupg patch openssl lsb-release psmisc \
        lsof iputils-ping iproute2 htop elinks less \
        tzdata locales tmux wget
#
#RUN apt-get -qq clean && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
#
# Install nodejs and yarn, Node.js LTS (v14.x):
##   https://github.com/nodesource/distributions/blob/master/README.md#debinstall
#RUN curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
#RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#RUN sudo apt-get update && sudo apt-get -qq install -y yarn nodejs
#
# clean if you want
RUN apt-get -qq clean && rm -rf /var/lib/apt/lists/*
#
# Configure sudo.
RUN ex +"%s/^%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/g" -scwq! /etc/sudoers
# Configure SSHD.
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir /var/run/sshd
RUN bash -c 'install -m755 <(printf "#!/bin/sh\nexit 0") /usr/sbin/policy-rc.d'
RUN ex +'%s/^#\zeListenAddress/\1/g' -scwq /etc/ssh/sshd_config
RUN ex +'%s/^#\zeHostKey .*ssh_host_.*_key/\1/g' -scwq /etc/ssh/sshd_config
RUN ex +'%s/^#\zeUseDNS/\1/g' -scwq /etc/ssh/sshd_config
RUN sed -i 's!^#PasswordAuthentication yes!PasswordAuthentication no!' /etc/ssh/sshd_config
#
RUN RUNLEVEL=1 dpkg-reconfigure openssh-server
RUN ssh-keygen -A -v
RUN update-rc.d ssh defaults
### 不要把key打包进去，每个实例启动应该生成自己的key文件...
RUN rm -rf /etc/ssh/*key*
#
#
# ### 不需要把tini打包进去，启动参数 --init 已经可以完成这个事了...
# # Add Tini
# ENV TINI_VERSION v0.19.0
# ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
# RUN chmod +x /tini
# ENTRYPOINT ["/tini", "--"]
#
#### 还是用脚本进行启动比较好，方便做很多，但要注意，这个脚本结束就意味这实例结束哦!
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
#
#
# Setup the default user.
RUN groupadd --gid 1000 ubuntu
RUN useradd --create-home --system -d /home/ubuntu -s /bin/bash --uid 1000 --gid 1000 --groups 'root,sudo' ubuntu
RUN echo 'ubuntu:Pa$$w0rd$' | chpasswd
#
USER ubuntu
WORKDIR /home/ubuntu
#
# Generate and configure user keys.  [ ecdsa, rsa, ed25519, dsa ]
USER ubuntu
RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
COPY --chown=ubuntu:ubuntu "./authorized_keys" /home/ubuntu/.ssh/authorized_keys
#
#
# Install oh-my-zsh
#RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
#
# Setup default command and/or parameters.
EXPOSE 22
# CMD ["sleep", "infinity"]
# CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]
# HEALTHCHECK --interval=60s --timeout=15s CMD netstat -lntp | grep -q '0\.0\.0\.0:22'
CMD ["/entrypoint.sh"]
