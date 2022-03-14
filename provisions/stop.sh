#!/bin/bash

# stop drone
docker-compose --env-file /vagrant_data/drone/.env -f /vagrant_data/drone/docker-compose.yml  down 

# stop gitea
docker-compose --env-file /vagrant_data/gitea/.env -f /vagrant_data/gitea/docker-compose.yml  down

