#!/bin/bash

echo "Clearing every previous file before starting"
echo "y" | ./scripts/stop_and_cleanup.sh

echo "Starting 2 nodes in 2 regions"
./scripts/create_and_start.sh 2 2

for ((i=0; i<240; i++)); do
    echo -ne "Slept for: $i\r"
    sleep 1
done

echo "Stopping one of those three nodes, making coordinator part of replicas"
docker kill region-1-database-2

echo "Sleeping for 60 seconds for the other 3 nodes to become \"owners\" of the data"
for ((i=0; i<60; i++)); do
    echo -ne "Slept for: $i\r"
    sleep 1
done

echo "Initializing keyspace with RF=3, and inserting a bunch of data"
./scripts/init_keyspace_and_tables.sh

echo "Sleeping for 90 seconds in order to generate hinted handoffs"
for ((i=0; i<90; i++)); do
    echo -ne "Slept for: $i\r"
    sleep 1
done

echo "Starting the killed node back up, sending the hinted handoffs"
docker start region-1-database-2
