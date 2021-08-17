#!/bin/bash -e

mkdir -p /root/.ssh
touch /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
echo $PUBLIC_KEY > /root/.ssh/authorized_keys
sed -i 's/PermitRootLogin yes/PermitRootLogin without-password/' /etc/ssh/sshd_config
