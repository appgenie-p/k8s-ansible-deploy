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

# Пнуть кублет, если не отвечает
sudo systemctl status kubelet

sudo systemctl stop kubelet
sudo systemctl start kubelet
strace -eopenat kubectl version

# Установка - рабочий гид.
# https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/
# https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-18-04

# Установка кластера
sudo kubeadm init --apiserver-advertise-address=10.0.1.9

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
ll $HOME/.kube/config
kubectl get namespace
kubectl cluster-info
kubectl get pod -n kube-system

# унижтожение ноды кластера
sudo kubeadm reset -f &&
rm $HOME/.kube/config &&
sudo rm /etc/cni/net.d

# Проверить статус кластера
kubectl get pod -n kube-system
kubectl cluster-info
sudo netstat -pnlt | grep 6443
kubectl get namespace
kubectl get nodes

# Дебаг проблем с кластером
kubectl cluster-info dump
sudo netstat -pnlt | grep 6443
# tcp6 0 0 :::6443 :::* LISTEN 4546/kube-apiserver
journalctl -xeu kubelet

# Возможно здесь решение:
# https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/troubleshooting-cni-plugin-related-errors/

