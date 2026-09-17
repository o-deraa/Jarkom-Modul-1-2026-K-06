#!/bin/bash

# ==========
# Node Lain
# ==========
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -C POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE
EOF

cat > /root/cek_status.sh <<'EOF'
#!/bin/sh

echo "===== STATUS INTERFACE ====="
ip -br a

echo
echo "===== STATUS NAT ====="
iptables -t nat -L -v -n
EOF
chmod +x /root/cek_status.sh


# ==========
# Node Alice
# ==========
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.1.2
    netmask 255.255.255.0
    gateway 192.214.1.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF

# ==========
# Node Mika
# ==========
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.1.3
    netmask 255.255.255.0
    gateway 192.214.1.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF

# ==========
# Node Chisa
# ==========
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.2.2
    netmask 255.255.255.0
    gateway 192.214.2.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF

# ============
# Node Knights
# ============
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.3.2
    netmask 255.255.255.0
    gateway 192.214.3.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF

# ==========
# Node Eiri
# ==========
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.3.3
    netmask 255.255.255.0
    gateway 192.214.3.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF