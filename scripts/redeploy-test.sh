#!/bin/sh

docker-compose --project-name komunitin-test --file /opt/komunitin-deploy/docker-compose.test.yml down --volumes
docker system prune -f
docker-compose --project-name komunitin-test --file /opt/komunitin-deploy/docker-compose.test.yml up -d --build --pull always
