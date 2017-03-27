VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box='clink15/pxe'

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--cpus", 1]
    v.customize ["modifyvm", :id, "--memory", 512]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--nattftpfile1", "pxelinux.0"]
    v.customize ["modifyvm", :id, "--nattftpserver1", "192.168.56.2"]
    v.customize ["modifyvm", :id, "--natnet1", "192.168.56/24"]
    v.customize ["modifyvm", :id, "--cableconnected1", "on"] # ensure that the network cable is connected. See chef/bento#688
    v.gui = true
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true
end
