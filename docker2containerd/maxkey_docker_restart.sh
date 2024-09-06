#!/bin/bash

echo "start MaxKey ... "

#MySQL
nerdctl -n maxkey.top restart maxkey-mysql
sleep 1

#maxkey
nerdctl -n maxkey.top restart maxkey
sleep 1

#maxkey-mgt
nerdctl -n maxkey.top restart maxkey-mgt
sleep 1

#maxkey-frontend
nerdctl -n maxkey.top restart maxkey-frontend
sleep 1

#maxkey-mgt-frontend
nerdctl -n maxkey.top restart maxkey-mgt-frontend
sleep 1

#maxkey-nginx proxy
nerdctl -n maxkey.top restart maxkey-nginx
sleep 1

nerdctl -n maxkey.top ps -a

echo "started done."
