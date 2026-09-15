#!/bin/bash

cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
    address 192.214.3.3
    netmask 255.255.255.0
    gateway 192.214.3.1
EOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf