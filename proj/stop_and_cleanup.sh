#!/bin/bash

# Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run this script as root or using sudo."
  exit 1
fi

read -p "⚠️  This will remove all containers, volumes, and local data. Continue? (y/N) " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "❌ Aborted."
  exit 1
fi

echo "Stopping and removing containers..."
docker compose down -v --remove-orphans

echo "Removing local data directories..."
rm -rf ./volumes
rm -rf ./db_files
rm -f ./docker-compose.yml

echo "✅ Cleanup complete."

