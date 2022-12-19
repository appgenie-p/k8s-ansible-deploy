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

sudo kubeadm init --apiserver-advertise-address=10.0.1.9
____________

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.2.15:6443 --token dmr6fh.g8tjkaf80a8tp9jw \
        --discovery-token-ca-cert-hash sha256:fd2fb95c0cd36fa80a048325681909eb5835259b48bb3be12b4c3eb0f4dd4c68 
_____________

sudo systemctl stop kubelet
sudo systemctl start kubelet
strace -eopenat kubectl version