#!/bin/bash
# Node: Chisa

apk update
apk add busybox-extras

adduser -D phantom_user
echo "phantom_user:wired_ghost" | chpasswd

telnetd -p 23