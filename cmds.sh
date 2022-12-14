# https://medium.com/linuxstories/vagrant-create-a-multi-machine-environment-b90738383a7e
# ansible-playbook -i inventory.yaml git-install.yml -vv

ssh vagrant@192.168.1.188 -i ~/.vagrant.d/insecure_private_key
ansible all -m ping -i ansible_hosts.cfg

https://github.com/devopsgroup-io/vagrant-hostmanager
vagrant plugin install vagrant-hostmanager
vagrant hostmanager

ansible-playbook -c local -i localhost, playbooks/git-config.yml -CD

