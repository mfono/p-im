# -*- mode: ruby -*-
# vi: set ft=ruby :

$bootstrap = <<BOOTSTRAPSCRIPT
BOOTSTRAPSCRIPT

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "2048"]
    v.customize ["modifyvm", :id, "--cpus", "2"]
    v.customize ["modifyvm", :id, "--vram", "64"]
    v.gui = true
  end

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"

  config.vm.host_name = "iron-mountain.dev"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8080

  # Enable provisioning with Puppet stand alone
  config.vm.provision :puppet do |puppet|
    puppet.module_path    = "~/vagrant/manifests"
    puppet.module_path    = "modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "iron_mountain_dev_vm.pp"
  end

  #config.vm.provision :shell, inline: $bootstrap
end
