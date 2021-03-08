#!/usr/bin/env bash
#
# sshd() {
#     /usr/bin/ssh-keygen -A
#     /usr/sbin/sshd
# }
#
# crond() {
#     /usr/sbin/crond
# }
#
# main() {
#     sshd
#     crond
#     /bin/bash
# }
#
# main
#

# 重新生成ssh服务的机器key
echo "[+] ssh-keygen ..."
/usr/bin/sudo /usr/bin/ssh-keygen -A -v
md5sum /etc/ssh/*.pub
echo "[+] done"

# 普通用户自定义启动运行脚本
echo "[+] ~/.local/auto.sh ..."
if [[ -x /home/ubuntu/.local/auto.sh ]]; then
    /home/ubuntu/.local/auto.sh
fi
echo "[+] done"

# 最后启动 ssh 服务，用前台方式启动，不退出的...
echo "[+] sshd ..."
/usr/bin/sudo /usr/sbin/sshd -D -o ListenAddress=0.0.0.0
echo "[+] done"
