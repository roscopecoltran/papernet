#!/bin/env ruby
# encoding: utf-8

VAGRANTFILE_API_VERSION = 2

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.ssh.forward_agent = true

  config.vm.define "papernet" do |papernet|
    papernet.vm.hostname = "papernet"
    papernet.vm.network "private_network", ip:"192.168.50.3"
    papernet.vm.network "forwarded_port", guest: 80, host: 9080

    papernet.vm.box = "bento/ubuntu-16.04"

    papernet.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]

      # To avoid blocking on "SSH auth method: private key" with the bento image
      # https://github.com/chef/bento/issues/682
      vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
    end

    papernet.vm.provision "ansible" do |ansible|
      ansible.playbook = "vagrant.yml"
      ansible.verbose = "vv"
      ansible.inventory_path = "dev/inventory"
      ansible.raw_arguments = ["--vault-password-file=vault_pass.txt"]
    end

  end

end
