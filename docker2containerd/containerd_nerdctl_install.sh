#!/bin/bash

#####################
### 安装 nerdctl
### 2024年08月29日
### 太一
#####################

# see https://github.com/containerd/nerdctl/releases for the latest release
NERDCTL_VERSION=1.7.6
DOWN_DIR=/tmp/nerdctl
SAVE_DIR=/opt/nerdctl

# 系统核心
archType="amd64"
if test "$(uname -m)" = "aarch64"; then
    archType="arm64"
fi
# 下载
mkdir -p ${DOWN_DIR}
if [[ ! -f "${DOWN_DIR}/nerdctl.tar.gz" ]]; then
    wget --no-check-certificate "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-full-${NERDCTL_VERSION}-linux-${archType}.tar.gz" -O ${DOWN_DIR}/nerdctl.tar.gz
fi
# 解压
mkdir -p ${SAVE_DIR}
rm -rf ${SAVE_DIR:?}/*
tar -xzvf ${DOWN_DIR}/nerdctl.tar.gz -C ${SAVE_DIR}

# 添加环境变量(root权限)
cat >/etc/profile.d/nerdctl_profile <<EOF
# 开启系统代理
## nerdctl ##
# path
export PATH="\${PATH}:${SAVE_DIR}/bin/"
# cni
export CNI_PATH="${SAVE_DIR}/libexec/cni"
EOF
source /etc/profile.d/nerdctl_profile

# 软路由启动服务
cd /lib/systemd/system/ || exit
ln -s ${SAVE_DIR}/lib/systemd/system/buildkit.service buildkit.service
# build服务调整内置命令
sed -i 's/\/usr\/local\/bin/'${SAVE_DIR//\//\\/}'\/bin/g' ${SAVE_DIR}/lib/systemd/system/buildkit.service
# 启动
systemctl enable buildkit.service --now