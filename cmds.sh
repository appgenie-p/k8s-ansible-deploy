# https://medium.com/linuxstories/vagrant-create-a-multi-machine-environment-b90738383a7e
# ansible-playbook -i inventory.yaml git-install.yml -vv

ssh vagrant@192.168.1.188 -i ~/.vagrant.d/insecure_private_key
ansible all -m ping -i ansible_hosts.cfg

https://github.com/devopsgroup-io/vagrant-hostmanager
vagrant plugin install vagrant-hostmanager
vagrant hostmanager

ansible-playbook -c local -i localhost, playbooks/git-config.yml -CD

ansible -m debug -a 'var=hostvars[inventory_hostname]' localhost

sudo sysctl -a | grep net.ipv4.ip_forward -A 5 -B 5

deb amd64 https://download.docker.com/linux/ubuntu jammy stable

sudo apt-get install containerd.io

containerd config default | sudo tee /etc/containerd/config.toml

ansible master -m shell -a 'containerd config default'

apb playbooks/k8s-install.yaml --start-at-task 'Generate default file content' \
-l master -CD

