#!/bin/bash

echo "start MaxKey ... "
#MySQL
nerdctl -n maxkey.top run -p 3306:3306 \
	-v ./docker-mysql/data:/var/lib/mysql \
	-v ./docker-mysql/logs:/var/log/mysql \
	-v ./docker-mysql/conf.d:/etc/mysql/conf.d \
	-v ./docker-mysql/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
	--name maxkey-mysql \
	--hostname maxkey-mysql \
	--network maxkey.top \
	-e MYSQL_ROOT_PASSWORD=maxkey \
	-m 1024M \
	--cpus 1 \
	-d docker.io/maxkeytop/mysql:latest

#maxkey
nerdctl -n maxkey.top run -p 9527:9527 \
	-e DATABASE_HOST=maxkey-mysql \
	-e DATABASE_PORT=3306 \
	-e DATABASE_NAME=maxkey \
	-e DATABASE_USER=root \
	-e DATABASE_PWD=maxkey \
	--name maxkey \
	--hostname maxkey \
	--network maxkey.top \
	-m 512M \
	--cpus 0.5 \
	-e JAVA_OPTS="-Xms125m -Xmx500m -Xss256k -XX:PermSize=80m -XX:MaxPermSize=150m -XX:+DisableExplicitGC" \
	-d docker.io/maxkeytop/maxkey:latest

#maxkey-mgt
nerdctl -n maxkey.top run -p 9526:9526 \
	-e DATABASE_HOST=maxkey-mysql \
	-e DATABASE_PORT=3306 \
	-e DATABASE_NAME=maxkey \
	-e DATABASE_USER=root \
	-e DATABASE_PWD=maxkey \
	--name maxkey-mgt \
	--hostname maxkey-mgt \
	--network maxkey.top \
	-m 512M \
	--cpus 0.5 \
	-e JAVA_OPTS="-Xms125m -Xmx500m -Xss256k -XX:PermSize=80m -XX:MaxPermSize=150m -XX:+DisableExplicitGC" \
	-d docker.io/maxkeytop/maxkey-mgt:latest

#maxkey-frontend
nerdctl -n maxkey.top run -p 8527:8527 \
	--name maxkey-frontend \
	--hostname maxkey-frontend \
	--network maxkey.top \
	-m 512M \
	--cpus 0.5 \
	-d docker.io/maxkeytop/maxkey-frontend:latest

#maxkey-mgt-frontend
nerdctl -n maxkey.top run -p 8526:8526 \
	--name maxkey-mgt-frontend \
	--hostname maxkey-mgt-frontend \
	--network maxkey.top \
	-m 512M \
	--cpus 0.5 \
	-d docker.io/maxkeytop/maxkey-mgt-frontend:latest

#maxkey-nginx proxy
nerdctl -n maxkey.top run -p 80:80 \
	-v ./docker-nginx/default.conf:/etc/nginx/conf.d/default.conf \
	--name maxkey-nginx \
	--hostname maxkey-nginx \
	--network maxkey.top \
	-m 512M \
	--cpus 0.5 \
	-d docker.io/maxkeytop/maxkey-nginx

nerdctl -n maxkey.top ps -a

echo "started done."