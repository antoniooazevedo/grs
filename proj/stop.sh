#!/bin/bash

# Ensure the script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

echo "Stopping and removing all containers..."
docker compose down -v --remove-orphans

echo "Removing Scylla volumes..."
rm -rf ./volumes/db1/system* ./volumes/db1/data/* \
 ./volumes/db1/commitlog/* ./volumes/db1/hints/* ./volumes/db1/view_hints/*
rm -rf ./volumes/db2/system* ./volumes/db2/data/* \
 ./volumes/db2/commitlog/* ./volumes/db2/hints/* ./volumes/db2/view_hints/*
 
echo "Done. All data wiped."