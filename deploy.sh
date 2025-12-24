#!/bin/bash

# Check if the .env file is present
if [ ! -f .env ]; then
  echo "The .env file is missing. Please create it by copying the .env.template file."
  exit 1
fi

# Check if the komunitin-project-firebase-adminsdk.json is present
if [ ! -f komunitin-project-firebase-adminsdk.json ]; then
  echo "The komunitin-project-firebase-adminsdk.json file is missing. Please create it by downloading it from the Firebase Console."
  exit 1
fi

# Update the repository and check there are no errors
git pull
if [ $? -ne 0 ]; then
  echo "There was an error updating the repository."
  exit 1
fi

# Pull the latest images and check there are no errors
docker compose pull
if [ $? -ne 0 ]; then
  echo "There was an error pulling the latest images."
  exit 1
fi

# Rebuild & restart the containers
docker compose up -d --build
if [ $? -ne 0 ]; then
  echo "There was an error starting the containers."
  exit 1
fi

# Wait for the containers to start
sleep 10

# Install DB migrations in accounting service
docker compose exec accounting pnpm prisma migrate deploy
if [ $? -ne 0 ]; then
  echo "There was an error deploying the DB migrations in the accounting service."
  exit 1
fi

docker compose exec notifications-ts pnpm prisma migrate deploy
if [ $? -ne 0 ]; then
  echo "There was an error deploying the DB migrations in the notifications-ts service."
  exit 1
fi

# Update ices module in drupal integralces service
docker compose exec integralces drush up ices -y
if [ $? -ne 0 ]; then
  echo "There was an error updating the ices module in the integralces service."
  exit 1
fi

# Remove unused docker data
docker system prune -f
