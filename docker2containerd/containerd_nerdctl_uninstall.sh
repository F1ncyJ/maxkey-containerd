#!/bin/bash

#####################
### 卸载 nerdctl
### 2024年08月29日
### FancyJ
#####################

# 停止服务
systemctl stop buildkit.service --now
cd /lib/systemd/system/ || exit
rm buildkit.service

# 清除环境变量
{
	echo ""
} >/etc/profile.d/nerdctl_profile.sh
