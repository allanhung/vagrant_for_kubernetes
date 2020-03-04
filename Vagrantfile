# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.vm.provider 'virtualbox' do |vb|
   vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
  end
  config.vm.synced_folder "./kubernetes", "/vagrant", type: "rsync"
  $num_node = 4
  $num_master = 1
  (1..$num_master+$num_node).each do |i|
    if i <= $num_master
      node_name = "master#{i}"
    else
      node_name = "node#{i-$num_master}"
    end
    config.vm.define "#{node_name}" do |node|
      node.vm.box = "centos8"
      node.vm.hostname = "#{node_name}"
      if i <= $num_master
        ip = "172.17.8.#{i+100}"
      else
        ip = "172.17.8.#{i-$num_master+200}"
      end
      node.vm.network "private_network", ip: ip
      node.vm.provider "virtualbox" do |vb|
        if i <= $num_master
          vb.memory = "2048"
          vb.cpus = 2
        else
          vb.memory = "512"
          vb.cpus = 1
        end
        vb.name = "#{node_name}"
      end
      node.vm.provision  "shell",  path: "init.sh", args: [$num_master, $num_node]
    end
  end
end
