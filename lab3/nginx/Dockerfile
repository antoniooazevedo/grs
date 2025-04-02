FROM nginx
RUN apt update && apt install -y vim iproute2 iputils-ping tcpdump iptables dnsutils curl php-fpm

COPY ./favicon.ico /usr/share/nginx/html/favicon.ico
