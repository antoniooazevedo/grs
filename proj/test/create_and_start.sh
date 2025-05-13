#!/bin/bash

# === Configuration ===
REGION1="us"
REGION2="eu"
NODES_PER_REGION=3
IMAGE="scylladb/scylla:5.2"
SUBNET="172.20.0.0/16"
NETWORK_NAME="scylla-net"

# === Setup ===
mkdir -p db_files volumes
> docker-compose.yml

# === Docker Compose Header ===
cat <<EOF >> docker-compose.yml
version: '3.8'

services:
EOF

# === Generate Nodes ===
IP_BASE=2
generate_node() {
  NODE_NAME=$1
  REGION=$2
  IP_SUFFIX=$3
  RACK=$4

  VOLUME_DIR="./volumes/${NODE_NAME}"
  RACKDC_FILE="./db_files/rackdc-${NODE_NAME}.properties"

  mkdir -p "$VOLUME_DIR"

  echo "dc=${REGION}" > "$RACKDC_FILE"
  echo "rack=${RACK}" >> "$RACKDC_FILE"

  cat <<EOF >> docker-compose.yml
  ${NODE_NAME}:
    image: ${IMAGE}
    container_name: ${NODE_NAME}
    hostname: ${NODE_NAME}
    volumes:
      - ${VOLUME_DIR}:/var/lib/scylla
      - ${RACKDC_FILE}:/etc/scylla/cassandra-rackdc.properties
    command: [
      "--developer-mode", "1",
      "--seeds", "database-1",
      "--smp", "1",
      "--listen-address", "${NODE_NAME}",
      "--broadcast-address", "${NODE_NAME}",
      "--broadcast-rpc-address", "${NODE_NAME}",
      "--endpoint-snitch", "GossipingPropertyFileSnitch"
    ]
    networks:
      ${NETWORK_NAME}:
        ipv4_address: 172.20.0.${IP_SUFFIX}
    privileged: true

EOF
}

echo "Generating nodes..."

for ((i = 1; i <= NODES_PER_REGION; i++)); do
  generate_node "database-$i" "$REGION1" $((IP_BASE++)) "rack$i"
done

for ((j = 1; j <= NODES_PER_REGION; j++)); do
  IDX=$((NODES_PER_REGION + j))
  generate_node "database-$IDX" "$REGION2" $((IP_BASE++)) "rack$j"
done

# === Docker Network ===
cat <<EOF >> docker-compose.yml

networks:
  ${NETWORK_NAME}:
    driver: bridge
    ipam:
      config:
        - subnet: ${SUBNET}
EOF

# === Launch Cluster ===
echo "Bringing up the cluster..."
docker compose up -d

echo "Done. Nodes launched:"
docker ps --filter name=database

