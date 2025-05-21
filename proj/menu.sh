#!/bin/bash

# === Ensure script is run as root ===
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run this script as root or using sudo."
  exit 1
fi

# === Configuration ===
ENV_FILE_PATH=./utils

if [[ ! -f "$ENV_FILE_PATH/scylla.env" ]]; then
    echo "❌ scylla.env file not found! Exiting..."
    exit 1
fi

source "$ENV_FILE_PATH/scylla.env"


# ==== Configuration: Define menu options and commands/scripts ====
show_menu() {
  clear
  echo "==========================="
  echo "    Dynamo Testing Suite   "
  echo "==========================="
  echo "1) Create and start the containers"
  echo "2) Stop and clean-up the build files"
  echo "3) Initialize the database with keyspaces"
  echo "4) Interact with nodes"
  echo "5) Exit"
  echo
}

start_menu() {
    clear
    read -rp "Number of regions [1-5]: " n_regions
    read -rp "Number of nodes per region [1-5]: " n_nodes
    ./scripts/create_and_start.sh "$n_regions" "$n_nodes"
}

show_node_status() {
    clear
    PROJECT_NAME=$(basename "$PWD")

    mapfile -t containers < <(
        docker ps -a \
        --filter "label=com.docker.compose.project=$PROJECT_NAME" \
        --format "{{.Names}}:{{.Status}}" | sort
    )

    # Header
    printf "No  %-25s %-30s\n" "Container" "Status"
    printf "%0.s=" {1..60}
    echo

    # Output loop
    for i in "${!containers[@]}"; do
        IFS=":" read -r name status <<< "${containers[$i]}"
        printf "%-3d %-25s %-30s\n" $((i + 1)) "$name" "$status"
    done
}

node_menu() {
    while true; do

        show_node_status

        printf "%0.s=" {1..60}
        echo
        read -rp "Select a container number to interact with: " selected

        if ! [[ "$selected" =~ ^[0-9]+$ ]] || (( selected < 1 || selected > ${#containers[@]} )); then
            echo "Invalid selection."
            return 
        fi
        IFS=":::" read -r container_name _ <<< "${containers[$((selected-1))]}"

        clear

        echo "Selected container: $container_name"
        printf "%0.s=" {1..60}
        echo
        echo "1) Start | 2) Stop | 3) Stress | 4) Back" 
        read -rp "Select an option [1-4]: " choice

        case $choice in
            1) docker start "$container_name" ;;
            2) docker stop "$container_name" ;;
            3) stress_menu ;;
            4) return ;;
            *)
                echo "Invalid option. Please try again."
            ;;
        esac
    done
}

get_container_ip() {
    local container_name="$1"

    # Extract network names the container is connected to
    local network=$(docker inspect "$container_name" | jq -r '.[0].NetworkSettings.Networks | to_entries[0].value.IPAddress')
    echo $network
}

get_network_by_suffix() {
    local suffix="$1"
    docker network ls --format '{{.Name}}' | awk -v s="$suffix" '$0 ~ s"$"'
}

stress_menu() {
    printf "%0.s=" {1..60}
    echo
    while true; do
        ip=$(get_container_ip "$container_name")
        full_network_name=$(get_network_by_suffix "$NETWORK_NAME")
        echo "Selected container IP on $full_network_name: $ip"
        echo "1) Read | 2) Write | 3) Read/Write | 4) Counter Write | 5) Back" 
        read -rp "Select a stress-test to perform [1-6]: " choice

        case $choice in
            1) docker run --rm --network "$full_network_name" scylladb/cassandra-stress:3.17.0 "cassandra-stress write -node $ip -mode native cql3" ;;
            2) docker run --rm --network "$full_network_name" scylladb/cassandra-stress:3.17.0 "cassandra-stress read -node $ip -mode native cql3" ;;
            3) docker run --rm --network "$full_network_name" scylladb/cassandra-stress:3.17.0 "cassandra-stress mixed ratio\(read=50,write=50\) -node $ip -mode native cql3" ;;
            4) docker run --rm --network "$full_network_name" scylladb/cassandra-stress:3.17.0 "cassandra-stress counter_write -node $ip -mode native cql3" ;;
            5) return ;;
            *)
                echo "Invalid option. Please try again."
                clear
                continue
            ;;
        esac
        read -rp "Press Enter to continue..."
        return
    done
}

# ==== Main loop ====
while true; do
  show_menu
  read -rp "Select an option [1-5]: " choice

  case $choice in
    1)
        start_menu 
      ;;
    2)
        ./scripts/stop_and_cleanup.sh
      ;;
    3)
        ./scripts/init_keyspace_and_tables.sh 
      ;;
    4)
        node_menu 
      ;;
    5)
      echo "Exiting. Goodbye!"
      exit 0
      ;;
    *)
      echo "Invalid option. Please try again."
      ;;
  esac
done
