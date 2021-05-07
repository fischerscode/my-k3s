Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"

  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/me.pub"

  config.vm.provision "shell", inline: <<-EOC
    cat /home/vagrant/.ssh/me.pub >> /home/vagrant/.ssh/authorized_keys
    sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd.service
  EOC

  config.vm.synced_folder ".", "/vagrant", disabled: true
#   config.vm.network "public_network", type: "dhcp", :bridge => 'en0: Ethernet'

  (1..5).each do |i|
    config.vm.define "k3s#{i}.test" do |node|
        node.vm.hostname = "knode#{i}.test"
        node.vm.network "private_network", ip: "172.16.17.10#{i}"
#         node.vm.network "public_network", ip: "192.168.178.10#{i}"
        node.vm.network "private_network", ip: "fd34:fe56:7891:2f3b::#{i}"
        node.vm.provider "virtualbox" do |v|
          v.name = "k3s#{i}.test"
          v.memory = 2048
          v.cpus = 2
        end
    end
  end

end