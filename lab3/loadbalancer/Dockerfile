FROM nginx
RUN apt update && apt install -y vim iproute2 iputils-ping tcpdump iptables dnsutils curl nagios-nrpe-server nagios-plugins
#RUN ip route add 10.0.1.0/24 via 10.0.1.254
RUN rm /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

COPY start.sh /root/start.sh
ENTRYPOINT []
CMD /root/start.sh
#CMD /root/start.sh; nginx -g daemon off

