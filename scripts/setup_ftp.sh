#!/bin/bash

# Install vsftpd jika belum ada
apk add --no-cache vsftpd >/dev/null 2>&1

# Daftarkan shell nologin untuk akun FTP
grep -qxF "/sbin/nologin" /etc/shells || echo "/sbin/nologin" >> /etc/shells

# Shared folder
SHARED="/var/wired/data"
mkdir -p "$SHARED"

# Buat user FTP jika belum ada
id alice >/dev/null 2>&1 || adduser -D -h "$SHARED" -s /sbin/nologin alice
echo "alice:alice123" | chpasswd

id mika >/dev/null 2>&1 || adduser -D -h "$SHARED" -s /sbin/nologin mika
echo "mika:mika123" | chpasswd

id eiri >/dev/null 2>&1 || adduser -D -h "$SHARED" -s /sbin/nologin eiri
echo "eiri:eiri123" | chpasswd

# Pastikan home directory setiap user adalah shared folder
sed -i 's|^alice:.*$|alice:x:1000:1000::/var/wired/data:/sbin/nologin|' /etc/passwd
sed -i 's|^mika:.*$|mika:x:1001:1001::/var/wired/data:/sbin/nologin|' /etc/passwd
sed -i 's|^eiri:.*$|eiri:x:1002:1002::/var/wired/data:/sbin/nologin|' /etc/passwd

# Permission shared folder
chown alice:alice "$SHARED"
chmod 755 "$SHARED"

# Konfigurasi utama vsftpd
cat > /etc/vsftpd/vsftpd.conf <<'CFG'
listen=YES
listen_ipv6=NO
listen_address=0.0.0.0
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
user_config_dir=/etc/vsftpd_users
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd.user_list
seccomp_sandbox=NO
CFG

# User yang diizinkan login FTP
cat > /etc/vsftpd.user_list <<'USERS'
alice
mika
USERS

# Konfigurasi per-user
mkdir -p /etc/vsftpd_users

cat > /etc/vsftpd_users/alice <<'ALICE'
local_root=/var/wired/data
write_enable=YES
ALICE

cat > /etc/vsftpd_users/mika <<'MIKA'
local_root=/var/wired/data
write_enable=NO
MIKA

# Restart vsftpd menggunakan konfigurasi terbaru
killall vsftpd 2>/dev/null || true
vsftpd /etc/vsftpd/vsftpd.conf &