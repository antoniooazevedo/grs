#!/bin/bash

# === Configuration ===
ENV_FILE_PATH=./utils

if [[ ! -f "$ENV_FILE_PATH/scylla.env" ]]; then
    echo "❌ scylla.env file not found! Exiting..."
    exit 1
fi

source "$ENV_FILE_PATH/scylla.env"

# === Run cqlsh in one of the databases ===

docker cp "$ENV_FILE_PATH/init.cql" "$REGION_PREFIX-1-database-1:/tmp/init.cql"
docker exec -it "$REGION_PREFIX-1-database-1" cqlsh -f "/tmp/init.cql"
