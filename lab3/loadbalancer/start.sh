#!/bin/bash

/sbin/ip route replace default via 172.16.123.142
/sbin/ip route add 10.0.1.0/24 via 172.16.123.142
nginx -g "daemon off;"

