#!/bin/bash

# ==============
# Node Knights
# ==============
apk update
apk add openssh
adduser -D mika_admin
ssh-keygen -A

# Set password untuk mika_admin (opsional jika jika hanya perlu public key)
passwd mika_admin

echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
/usr/sbin/sshd

mkdir -p /home/mika_admin/.ssh
chmod 700 /home/mika_admin/.ssh

# Konfigurasi di bawah ini akan dijalankan setelah public key dari Mika dimasukkan ke authorized_keys
# chmod 600 /home/mika_admin/.ssh/authorized_keys
# chown -R mika_admin:mika_admin /home/mika_admin/.ssh
# chmod 755 /home/mika_admin
# chown mika_admin:mika_admin /home/mika_admin


# ==============
# Node Mika
# ==============
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate key tanpa password (passphrase kosong)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""

chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Tampilkan public key untuk di-copy ke node Knights (ke file /home/mika_admin/.ssh/authorized_keys)
cat ~/.ssh/id_ed25519.pub