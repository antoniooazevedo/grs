#!/bin/bash

# === Configuration ===
ENV_FILE_PATH=./utils

if [[ ! -f "$ENV_FILE_PATH/scylla.env" ]]; then
    echo "❌ scylla.env file not found! Exiting..."
    exit 1
fi

source "$ENV_FILE_PATH/scylla.env"

# === Verify minimum values ===
if [[ $NUMBER_OF_REGIONS -lt 1 || $NODES_PER_REGION -lt 1 ]]; then
    echo "❌ Number of regions or number of nodes per region too low (minimum 1). Exiting..."
    exit 1
fi

if [[ $(($NUMBER_OF_REGIONS * $NODES_PER_REGION)) -gt 10 ]]; then
    RED=$'\033[1;31m'
    NC=$'\033[0m'  
    printf "${RED}WARNING: \nThe amount of total nodes is greater than 10. You are running the risk of depleting the resources of the host machine, and therefore the containers won't work properly, or even startup. Reduce the number of regions or the number of nodes per region in the environment file in order to guarantee correct functionality.\n$NC"
fi

# === Ensure script is run as root ===
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run this script as root or using sudo."
  exit 1
fi

# === Adjust aio limit (needed for ScyllaDB) ===
if [ "$(cat /proc/sys/fs/aio-max-nr)" -lt 1048576 ]; then
    echo "fs.aio-max-nr too low, increasing..."
    sysctl -w fs.aio-max-nr=1048576
    echo "done"
fi 

# === Setup ===
mkdir -p db_files volumes
> docker-compose.yml

# === Docker Compose Header ===
cat <<EOF >> docker-compose.yml
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
      "--seeds", "$REGION_PREFIX-1-database-1",
      "--smp", "1",
      "--listen-address", "${NODE_NAME}",
      "--broadcast-address", "${NODE_NAME}",
      "--broadcast-rpc-address", "${NODE_NAME}",
      "--endpoint-snitch", "GossipingPropertyFileSnitch"
    ]
    networks:
      ${NETWORK_NAME}: 
        ipv4_address: ${IP_ADDR}.${IP_SUFFIX}
    privileged: true

EOF
}

echo "Generating docker-compose.yml file..."

for ((j = 1; j <= NUMBER_OF_REGIONS; j++)) do
    for ((i = 1; i <= NODES_PER_REGION; i++)); do
        generate_node "$REGION_PREFIX-$j-database-$i" "$REGION_PREFIX-$j" $((IP_BASE++)) "rack$i"
    done
done

# === Docker Network ===
cat <<EOF >> docker-compose.yml

networks:
  ${NETWORK_NAME}:
    driver: bridge
    ipam:
      config:
        - subnet: ${IP_ADDR}.0/16
EOF

# === Launch Cluster ===
echo "Bringing up the cluster..."
docker compose up -d

echo "Done. Nodes launched!"
echo "All nodes need around 45 seconds to be fully operational!"
echo "Please wait around a minute before executing any command on the nodes!"

