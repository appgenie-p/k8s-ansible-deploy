# https://www.knowledgehut.com/blog/devops/install-kubernetes-on-ubuntu

sudo vim /etc/hosts
10.0.1.9        k8smaster.example.net k8smaster
10.0.1.10       k8sworker1.example.net k8sworker1
10.0.1.11       k8sworker2.example.net k8sworker2

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

sudo apt install -y curl gnupg2 gnupg software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# master node
kubeadm config images pull
sudo kubeadm init --control-plane-endpoint=k8smaster.example.net

To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

# You can now join any number of control-plane nodes by copying certificate authorities
# and service account keys on each node and then running the following as root:

kubeadm join k8smaster.example.net:6443 --token 1l6k4e.ltz7nir2zua89z36 \
    --discovery-token-ca-cert-hash sha256:ae449314a8d35cd7633aaa3736a7c0af48501f47c49c2c2934d87b5dc2d5311f \
    --control-plane 

# Then you can join any number of worker nodes by running the following on each as root:

sudo kubeadm join k8smaster.example.net:6443 --token 1l6k4e.ltz7nir2zua89z36 \
    --discovery-token-ca-cert-hash sha256:ae449314a8d35cd7633aaa3736a7c0af48501f47c49c2c2934d87b5dc2d5311f

# #########################################
# [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
# [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
# [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"

curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
kubectl apply -f calico.yaml

# logs, можно использовать -n A, что бы вывести все namespaces
# https://github.com/projectcalico/calico/issues/3053
# https://kubernetes.io/docs/tasks/debug/debug-application/debug-init-containers/
# https://kubernetes.io/docs/tasks/debug/debug-application/
kubectl get pods -n kube-system -o wide
kubectl get pod <pod-name> -n kube-system -o wide
kubectl describe pod <pod-name> -n kube-system  -c install-cni
kubectl describe pod <pod-name> -n kube-system  -c install-cni --previous=true
kubectl logs -n kube-system <pod-name> -c install-cni
# Вывод в плохочитаемом формате JSON
kubectl get pod calico-node-gwrf4 --template '{{.status.initContainerStatuses}}' -n kube-system

# kubelet logs
sudo journalctl -xu kubelet --no-pager
sudo journalctl -xu kubelet --no-pager -S 2019-12-30 > kubelet.log

# init container
kubectl describe pod <pod-name>
# find strings 'init-container'
kubectl logs <pod-name> -c <init-container-2>
# #########################################

