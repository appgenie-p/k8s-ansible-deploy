# https://medium.com/linuxstories/vagrant-create-a-multi-machine-environment-b90738383a7e
# vagrant plugin install vagrant-hostmanager
# vagrant hostmanager

Vagrant.configure("2") do |config|
  config.ssh.insert_key = true

  config.vm.box_check_update = false
  # config.vm.provision :ansible do |ansible|
  #   ansible.playbook = "playbooks/remote-software.yaml"
  # end
  config.vm.define "master" do |master|
    check_guest_additions = false
    # master.vm.box = "ubuntu/jammy64"
    master.vm.box = "ubuntu/focal64"
    master.vm.hostname = "master"
    # master.vm.network "public_network",
    master.vm.network "private_network",
      # use_dhcp_assigned_default_route: true,
      # bridge: "en1: Wi-Fi (AirPort)",
      # adapter: "1",
      ip: "10.0.1.9"
      # ip: "192.168.1.9"
    master.vm.provider "virtualbox" do |vb|
      vb.linked_clone = true
      vb.name = "master"
      vb.memory = "2048"
      vb.cpus = 2
    end
  end

  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "playbooks/k8s-install.yaml"
  # end

  # (1..2).each do |i|
  (10..11).each do |i|
    config.vm.define "node-#{i}" do |node|
      check_guest_additions = false
      # node.vm.box = "ubuntu/jammy64"
      node.vm.box = "ubuntu/focal64"      
      node.vm.box_check_update = false
      node.vm.hostname = "node-#{i}"
      # node.vm.network "public_network",
      node.vm.network "private_network",
        # use_dhcp_assigned_default_route: true,
        # bridge: "en1: Wi-Fi (AirPort)",
        # adapter: "1",
        # ip: "192.168.1.#{i}"
        ip: "10.0.1.#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.name = "node-#{i}"
        vb.memory = "2048"
        vb.cpus = 2
      end
    end
  end
end



