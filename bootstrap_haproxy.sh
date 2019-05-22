#!/bin/bash

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.42.42.100 kmaster.example.com kmaster
172.42.42.101 kworker1.example.com kworker1
172.42.42.102 kworker2.example.com kworker2
EOF

# Install docker from Docker-ce repository
echo "[TASK 2] Install haproxy"
yum install -y -q haproxy > /dev/null 2>&1


echo "[TASK 3] Update haproxy.cfg"
cat >> /etc/haproxy/haproxy.cfg <<EOL

frontend http_front
  bind *:80
  stats uri /haproxy?stats
  default_backend http_back

backend http_back
  balance roundrobin
  server kube <worker-node1-ip>:80
  server kube <worker-node2-ip>:80
EOL

# Stop and disable firewalld
echo "[TASK 4] Stop and Disable firewalld"
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld

# Add sysctl settings
echo "[TASK 5] Add sysctl settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1

# Disable swap
echo "[TASK 6] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

# Enable ssh password authentication
echo "[TASK 7] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 8] Set root password"
echo "password" | passwd --stdin root >/dev/null 2>&1

# Update vagrant user's bashrc file
echo "export TERM=xterm" >> /etc/bashrc

