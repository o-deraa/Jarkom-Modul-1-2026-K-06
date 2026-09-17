#!/bin/bash
# Node: Lain (Router)

cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet dhcp
        hostname alpinet-1
EOF
