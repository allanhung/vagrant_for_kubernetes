#!/usr/bin/env bash

num_master=$1
num_node=$2
/bin/cp -f /usr/share/zoneinfo/Asia/Taipei /etc/localtime
timedatectl set-timezone Asia/Taipei
# disable selinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
# docker-ce repo
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
# kubernetes repo
cat > /etc/yum.repos.d/kubernetes.repo << EEE
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EEE
dnf install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
dnf install -y wget vim net-tools telnet tcpdump bind-utils dos2unix chrony git tc docker-ce kubelet kubeadm kubectl 
systemctl enable --now chronyd
systemctl enable --now docker
cat > /etc/sysctl.d/k8s.conf <<EEE
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
EEE
sysctl -p
swapoff -a
sed -i -e "/swap/s/^/#/g" /etc/fstab
cat > /etc/hosts << EEE
127.0.0.1       localhost localhost.localdomain localhost4 localhost4.localdomain4
::1             localhost localhost.localdomain localhost6 localhost6.localdomain6
EEE
for i in $(seq 1 $num_master); do
  echo "172.17.8.$(($i+100))    master$i" >> /etc/hosts
done
for i in $(seq 1 $num_node); do
  echo "172.17.8.$(($i+200))    node$i" >> /etc/hosts
done
