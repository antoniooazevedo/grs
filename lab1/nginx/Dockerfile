FROM nginx

RUN apt update && apt install -y vim iproute2 iputils-ping tcpdump iptables dnsutils curl

COPY start.sh /home/start.sh

ENTRYPOINT []

CMD /home/start.sh
