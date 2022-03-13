#!/bin/bash

# init gitea
[ ! -d "/vagrant_data/data/gitea" ] && mkdir -p /vagrant_data/data/gitea
docker-compose --env-file /vagrant_data/gitea/.env -f /vagrant_data/gitea/docker-compose.yml  up -d 


# EOF
