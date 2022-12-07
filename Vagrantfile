Vagrant.configure("2") do |config|
  config.vm.define "master" do |master|
    check_guest_additions = false
    master.vm.box = "ubuntu/jammy64"
    master.vm.box_check_update = false
    master.vm.hostname = "master"
    master.ssh.insert_key = false
    master.vm.network "public_network",
      use_dhcp_assigned_default_route: true,
      bridge: "en1: Wi-Fi (AirPort)",
      ip: "192.168.1.188"
    master.vm.provider "virtualbox" do |vb|
      vb.linked_clone = true
      vb.name = "master"
      vb.memory = "2048"
      vb.cpus = 2
    end
  end

  (1..2).each do |i|
    config.vm.define "node-#{i}" do |node|
      check_guest_additions = false
      node.vm.box = "ubuntu/jammy64"
      node.vm.box_check_update = false
      node.vm.hostname = "node-#{i}"
      node.ssh.insert_key = false
      node.vm.network "public_network",
        use_dhcp_assigned_default_route: true,
        bridge: "en1: Wi-Fi (AirPort)"
      node.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.name = "node-#{i}"
        vb.memory = "2048"
        vb.cpus = 2
      end
    end
  end
end



