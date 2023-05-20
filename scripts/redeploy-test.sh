#!/bin/bash

docker-compose --project-name komunitin-test --file /opt/komunitin-deploy/docker-compose.test.yml down --volumes
docker system prune -f

docker-compose --file /opt/komunitin-deploy/docker-compose.test.yml pull
docker-compose --project-name komunitin-test --file /opt/komunitin-deploy/docker-compose.test.yml up -d --build
