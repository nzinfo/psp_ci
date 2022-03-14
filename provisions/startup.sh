#!/bin/bash

# start gitea
[ ! -d "/vagrant_data/data/gitea" ] && mkdir -p /vagrant_data/data/gitea
docker-compose --env-file /vagrant_data/gitea/.env -f /vagrant_data/gitea/docker-compose.yml  up -d 

# start drone.io
[ ! -d "/vagrant_data/data/drone" ] && mkdir -p /vagrant_data/data/drone

# 构造配置信息
source /vagrant_data/drone/drone_with_gitea.sh

# 用于配置 drone 的 OAuth 信息
# DRONE_OAUTH_APP_CLIENT_ID='na'
# DRONE_OAUTH_APP_CLIENT_SECRET='' 
GITEA_CLIENT_ID='na'
GITEA_CLIENT_SECRET=''

export GITEA_CLIENT_ID=`cat /vagrant_data/data/drone/oauth_secret.json | jq -r '.client_id' `
export GITEA_CLIENT_SECRET=`cat /vagrant_data/data/drone/oauth_secret.json | jq -r '.client_secret' `
export GIT_SERVER_NAME="gitea.pdev"
export CI_SERVER_NAME="drone.pdev"
export GITTEA_SERVER_PORT=8080         

if [[ -n $GITEA_CLIENT_SECRET ]];
then
    docker-compose --env-file /vagrant_data/drone/.env -f /vagrant_data/drone/docker-compose.yml  up -d 
fi 

# EOF
