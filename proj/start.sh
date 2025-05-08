#!/bin/bash

# Ensure the script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

if [ "$(cat /proc/sys/fs/aio-max-nr)" -lt 1048576 ]; then
    echo "aio-max-nr too low, increasing..."
    sysctl -w fs.aio-max-nr=1048576
    echo "done"
fi 

docker compose build
docker compose up -d

echo "Sleeping 60 secs until containers start..."

for i in {1..60}; do
    echo -ne "\r\033[K $i..."
    sleep 1
done

echo -e "\nDone sleeping!"

for container in $(docker ps --format '{{.Names}}' | grep '^database-'); do
  echo "Running CQL on $container"
  echo "OUTPUT ###############################"
  docker exec "$container" cqlsh -f /init.cql
  echo "######################################"
done

echo "Done! Check cqlsh for healthy containers"