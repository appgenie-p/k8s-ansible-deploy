# https://medium.com/linuxstories/vagrant-create-a-multi-machine-environment-b90738383a7e

ssh vagrant@192.168.1.188 -i ~/.vagrant.d/insecure_private_key
-o StrictHostKeyChecking=false
ansible all -m ping -i ansible_hosts.cfg

https://github.com/devopsgroup-io/vagrant-hostmanager
vagrant plugin install vagrant-hostmanager
vagrant hostmanager

# [vms:vars]
# ansible_ssh_port=22
# ansible_ssh_user=vagrant
# ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key
# ansible_ssh_common_args: '-o StrictHostKeyChecking=false'