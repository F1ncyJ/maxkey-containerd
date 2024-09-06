#!/bin/bash

## 基于 nerdctl 拉取镜像 ###
echo "Place Nerdctl Login First"
nerdctl login

# 利用命名空间来隔离
echo "namespace create "
nerdctl namespace create maxkey.top

# 创建网络
echo "network create "
nerdctl -n maxkey.top network create maxkey.top

#MySQL
mysql_version=8.0.32
nerdctl -n maxkey.top image pull docker.io/library/mysql:$mysql_version
nerdctl -n maxkey.top image tag docker.io/library/mysql:$mysql_version docker.io/maxkeytop/mysql

sleep 2
#maxkey
nerdctl -n maxkey.top image pull docker.io/maxkeytop/maxkey:latest

sleep 2
#maxkey-mgt
nerdctl -n maxkey.top image pull docker.io/maxkeytop/maxkey-mgt:latest

sleep 2
#maxkey-frontend
nerdctl -n maxkey.top image pull docker.io/maxkeytop/maxkey-frontend:latest

sleep 2
#maxkey-mgt-frontend
nerdctl -n maxkey.top image pull docker.io/maxkeytop/maxkey-mgt-frontend:latest

sleep 2
#maxkey-nginx proxy
nerdctl -n maxkey.top image pull docker.io/library/nginx
nerdctl -n maxkey.top image tag docker.io/library/nginx docker.io/maxkeytop/maxkey-nginx

echo "installed done."