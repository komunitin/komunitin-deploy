#!/bin/sh

docker stop komunitin-app
docker system prune -f
docker pull komunitin/komunitin-app:latest
docker run -p 2030:80 -d --name=komunitin-app --env USE_MIRAGE=200 --restart unless-stopped komunitin/komunitin-app:latest
