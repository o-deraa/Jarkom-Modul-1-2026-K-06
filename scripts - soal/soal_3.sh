#!/bin/bash

# ===========
# Node Alice
# ===========
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 192.214.1.2
    netmask 255.255.255.0
    gateway 192.214.1.1
EOF

# ===========
# Node Mika
# ===========
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 192.214.1.3
    netmask 255.255.255.0
    gateway 192.214.1.1
EOF

# ===========
# Node Chisa
# ===========
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 192.214.2.2
    netmask 255.255.255.0
    gateway 192.214.2.1
EOF

# ============
# Node Knights
# ============
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 192.214.3.2
    netmask 255.255.255.0
    gateway 192.214.3.1
EOF

# ===========
# Node Eiri
# ===========
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 192.214.3.3
    netmask 255.255.255.0
    gateway 192.214.3.1
EOF