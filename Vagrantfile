VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box='boxcutter/ubuntu1604'
  config.vm.box_version = '2.0.26'
  config.vm.network "private_network", ip: "192.168.0.5", virtualbox__intnet: true
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--cpus", 1]
    v.customize ["modifyvm", :id, "--memory", 512]
  end
  config.vm.provision "shell", path: "provisioning/dnsmasq.sh"
  config.vm.synced_folder '.', '/vagrant', disabled: true
end
