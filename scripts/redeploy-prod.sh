#!/bin/sh

docker compose --file /opt/komunitin-deploy/docker-compose.prod.yml pull
docker compose --project-name komunitin-prod --file /opt/komunitin-deploy/docker-compose.prod.yml up -d --build

