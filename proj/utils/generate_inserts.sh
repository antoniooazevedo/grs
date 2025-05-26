#!/bin/bash

OUTPUT="inserts.cql"
KEYSPACE="dynamo"
TABLE="users"

echo "-- CQL script to insert 100,000 users into ${KEYSPACE}.${TABLE}" > "$OUTPUT"

for i in $(seq 1 100000); do
    echo "INSERT INTO ${KEYSPACE}.${TABLE} (id, name) VALUES ($i, 'User$i');" >> "$OUTPUT"
done

echo "Generated $OUTPUT with 100,000 INSERT statements."

