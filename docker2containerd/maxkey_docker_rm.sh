#!/bin/bash

echo "rm MaxKey ... "

./maxkey_docker_stop.sh

#maxkey-nginx proxy
nerdctl -n maxkey.top rm maxkey-nginx

#maxkey-frontend
nerdctl -n maxkey.top rm maxkey-frontend

#maxkey-mgt-frontend
nerdctl -n maxkey.top rm maxkey-mgt-frontend

#maxkey
nerdctl -n maxkey.top rm maxkey

#maxkey-mgt
nerdctl -n maxkey.top rm maxkey-mgt

#MySQL
nerdctl -n maxkey.top rm maxkey-mysql

echo "rm done."