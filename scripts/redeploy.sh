#/bin/bash

docker stop komunitin-app
docker system prune -f
docker pull komunitin/komunitin-app:latest
docker run -d --name=komunitin-app komunitin/komunitin-app:latest
