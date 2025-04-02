FROM ubuntu:latest

# Install BIND 9 and necessary utilities
RUN apt-get update && apt-get install -y bind9 bind9utils bind9-doc dnsutils vim iproute2 iputils-ping tcpdump iptables vim iproute2 iputils-ping tcpdump iptables && rm -rf /var/lib/apt/lists/*

# Expose DNS ports
EXPOSE 53/udp 53/tcp

# Set up the entrypoint script
#COPY named.conf /etc/bind/named.conf
#COPY named.conf.options /etc/bind/named.conf.options
#COPY named.conf.local /etc/bind/named.conf.local
#COPY zones/ /etc/bind/zones/

# Set permissions
RUN chown -R bind:bind /etc/bind && chmod -R 755 /etc/bind

# Start BIND 9
#CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf"]

COPY start.sh /root/start.sh
ENTRYPOINT []
CMD /root/start.sh

