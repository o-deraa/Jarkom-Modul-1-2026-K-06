#!/bin/bash

cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet dhcp
        hostname alpinet-1
EOF

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.214.0.0/16
