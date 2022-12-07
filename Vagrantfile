Vagrant.configure("2") do |config|
  # config.hostmanager.enabled = true
  # config.hostmanager.manage_host = true
  # config.hostmanager.manage_guest = true
  # config.hostmanager.ignore_private_ip = false
  # config.hostmanager.include_offline = true

  config.vm.define "master" do |master|
    master.vm.box = "ubuntu/jammy64"
    check_guest_additions = false
    master.ssh.insert_key = false
    # config.ssh.host = "master"
    master.vm.allow_hosts_modification = true
    # master.vm.box_check_update = false
    # master.vm.hostname = "master"
    master.vm.network "public_network",
      use_dhcp_assigned_default_route: true,
      bridge: "en1: Wi-Fi (AirPort)",
      ip: "192.168.1.188"
    master.vm.provider "virtualbox" do |vb|
      vb.linked_clone = true
      # vb.gui = true
      # vb.name = "master"
      vb.memory = "2048"
      vb.cpus = 2
    end
  end

  # (1..2).each do |i|
  #   config.vm.define "node-#{i}" do |web|
  #     web.vm.box = "ubuntu/jammy64"
  #     web.ssh.insert_key = false
  #     web.vm.box_check_update = false
  #     web.vm.network "public_network",
  #       use_dhcp_assigned_default_route: true,
  #       bridge: "en1: Wi-Fi (AirPort)"
  #     web.vm.provider "virtualbox" do |vb|
  #       vb.linked_clone = true
  #       vb.name = "node-#{i}"
  #       vb.memory = "2048"
  #       vb.cpus = 2
  #     end
  #   end
  # end
end

# config.vm.network "public_network", bridge: "Intel(R) 82579LM Gigabit Network Connection"

# (1..3).each do |i|
#   config.vm.define "node-#{i}" do |node|
#     node.vm.provision "shell",
#       inline: "echo hello from node #{i}"
#   end
# end

# config.vm.network "private_network", type: "dhcp"
# config.vm.network "private_network", ip: "192.168.50.4"

# config.vm.network "forwarded_port", guest: 80, host: 8080


