FROM ubuntu:20.04
# baseline network tools
RUN apt update && apt install -y vim iproute2 iputils-ping tcpdump iptables dnsutils curl

# quagga

RUN apt update && apt install -y quagga systemctl
RUN apt update && apt install -y telnet
RUN mkdir -p /var/log/quagga
RUN chown quagga:quagga /var/log/quagga
RUN mkdir /run/quagga
RUN chmod a+w /run/quagga
COPY sleep.sh /home/sleep.sh
COPY start-ospf.sh /home/start-ospf.sh
COPY start-ospf-bgp.sh /home/start-ospf-bgp.sh

COPY config/ospfd.conf /etc/quagga/ospfd.conf
COPY config/zebra.conf /etc/quagga/zebra.conf

RUN chmod +x /home/start-ospf.sh
RUN chmod +x /home/start-ospf-bgp.sh
RUN chmod +x /home/sleep.sh
CMD /home/start-ospf.sh
