#!/bin/bash

echo "stop MaxKey ... "

#maxkey-nginx proxy
nerdctl -n maxkey.top stop maxkey-nginx

#maxkey-frontend
nerdctl -n maxkey.top stop maxkey-frontend

#maxkey-mgt-frontend
nerdctl -n maxkey.top stop maxkey-mgt-frontend

#maxkey
nerdctl -n maxkey.top stop maxkey

#maxkey-mgt
nerdctl -n maxkey.top stop maxkey-mgt

#MySQL
nerdctl -n maxkey.top stop maxkey-mysql

echo "stoped done."