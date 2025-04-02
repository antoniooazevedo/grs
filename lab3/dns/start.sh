#!/bin/bash

/sbin/ip route replace default via 172.16.255.254
/sbin/ip route add 10.0.1.0/24 via 172.16.123.142
/usr/sbin/named -g -c /etc/bind/named.conf -u bind
while true
 do
#       ab -k -c 100 -n 100000 http://10.0.2.100/
        /bin/sleep 1m
 done


