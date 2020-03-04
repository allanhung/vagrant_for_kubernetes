### prepear envirnment
```bash
brew cask install vagrant
brew cask install virtualbox
system --> security & privacy --> general --> Allow oracle user
brew cask reinstall --force virtualbox

vagrant box add centos8 https://cloud.centos.org/centos/8/vagrant/x86_64/images/CentOS-8-Vagrant-8.0.1905-1.x86_64.vagrant-virtualbox.box
vagrant box list
```

### kubernetes installation
```bash
git clone https://github.com/allanhung/vagrant_for_kubernetes
cd vagrant_for_kubernetes
sed -i -e "s/num_node =.*/num_node = 4/g" -e "s/num_master =.*/num_master = 1/g" Vagrantfile
vargrant up
vagrant ssh master1
sudo su -
# master
systemctl enable --now kubelet
export POD_CIDR="192.168.0.0/16"
export ADVERTISE_IP=`ip addr |grep 172.17.8|awk -F"/" {'print $1'}|awk {'print $2'}`
# calico network
curl -L -o calico.yaml https://docs.projectcalico.org/manifests/calico-typha.yaml
sed -i -e "s?10.244.0.0/16?${POD_CIDR}?g" calico.yaml
kubeadm init --apiserver-advertise-address=${ADVERTISE_IP} --control-plane-endpoint="`hostname`:6443" --pod-network-cidr="${POD_CIDR}" --ignore-preflight-errors=NumCPU | tee ~/kubeadm.out
mkdir -p /root/.kube && /bin/cp -f /etc/kubernetes/admin.conf /root/.kube/config
mkdir -p /home/vagrant/.kube && /bin/cp -f /root/.kube/config /home/vagrant/.kube && chown -R vagrant.vagrant /home/vagrant/.kube
kubectl apply -f calico.yaml
```
