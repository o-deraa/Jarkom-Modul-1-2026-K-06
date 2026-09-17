#!/bin/bash

# ================================
# Jalankan di tiap Node Client (Alice, Mika, Chisa, Knights, Eiri)
# ================================
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# ================================
# Setiap CLIENT NODE
# ================================
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.214.0.0/16
echo 1 > /proc/sys/net/ipv4/ip_forward