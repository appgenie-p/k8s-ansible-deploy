ssh vagrant@192.168.1.188 -i ~/.vagrant.d/insecure_private_key
ansible all -m ping -i ansible_hosts.cfg

# https://github.com/devopsgroup-io/vagrant-hostmanager
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

# Установка кластера - рабочий гид:
    # https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/
    # https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-18-04

cat /etc/containerd/config.toml | grep SystemdCgroup
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# Установка кластера
sudo kubeadm init --apiserver-advertise-address=10.0.1.9
# [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
# [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
# [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
ll $HOME/.kube/config

# унижтожение ноды кластера
sudo kubeadm reset -f &&
rm $HOME/.kube/config &&
sudo rm /etc/cni/net.d

# Проверить статус кластера
kubectl cluster-info
kubectl -n kube-system get cm kubeadm-config -o yaml
kubectl get svc
kubectl get namespace
kubectl get node -o wide
kubectl get pod -n kube-system -o wide
sudo netstat -pnlt | grep 6443
kubectl config view

# Network Add-ons
# https://www.weave.works/docs/net/latest/kubernetes/kube-addon/
# https://www.weave.works/docs/net/latest/install/installing-weave/

# Install CNI Add-on Weave Net
wget https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubectl apply -f weave-daemonset-k8s.yaml
kubectl get pod -n kube-system -o wide

# Подключить worker nodes
kubeadm token create --print-join-command
kubeadm join 10.0.1.9:6443 --token vzwoie.7hlnk7rqxb9pmwsh --discovery-token-ca-cert-hash sha256:846cf8a5a02d7dc65194b6885e88d2e14d2f7f1e24c6c15aa82f378cfbdcd4b2

# Проверить статус подключения:
curl 127.0.0.1:6784/status

# #########################################
# Дебаг проблем с кластером
# Debug
# https://kubernetes.io/docs/tasks/debug/debug-application/
# Debug Init Containers
# https://kubernetes.io/docs/tasks/debug/debug-application/debug-init-containers/

# https://github.com/projectcalico/calico/issues/3053

kubectl cluster-info dump
sudo netstat -pnlt | grep 6443
# tcp6 0 0 :::6443 :::* LISTEN 4546/kube-apiserver

# Отобразить логи kubelet
journalctl -u kubelet
journalctl -xeu kubelet
sudo journalctl -xu kubelet --no-pager
sudo journalctl -xu kubelet --no-pager -S 2019-12-30 > kubelet.log

# Получит события кластера
kubectl get events

# Получить информацию о поде
kubectl get pod <pod-name> -n kube-system -o wide
    kubectl get pod weave-net-8gk47 -n kube-system -o wide

kubectl describe pod <pod-name> -n kube-system
    kubectl describe pod weave-net-8gk47 -n kube-system

# Получить перечень контейнеров в поде:
kubectl get pods weave-net-8gk47 -o jsonpath='{.spec.containers[*].name}' -n kube-system
# or
kubectl describe pod <pod-name> -n kube-system | grep 'Image ID:'

# Посмотреть логи пода и контейнеров в нем
kubectl logs -n kube-system <pod-name>
    kubectl logs -n kube-system  weave-net-8gk47  

kubectl logs -n kube-system <pod-name> -c <container-name>
    kubectl logs -n kube-system  weave-net-8gk47 -c weave-npc
    kubectl logs -n kube-system  weave-net-8gk47 -c weave-kube

kubectl logs -n kube-system <pod-name> -c <container-name> --previous=true
    kubectl logs -n kube-system weave-net-8gk47 -c weave-npc --previous=true
    kubectl logs -n kube-system weave-net-8gk47 -c weave-kube --previous=true
# Статус контейнера
kubectl get pod <pod-name> --template '{{.status.initContainerStatuses}}' -n kube-system
    kubectl get pod weave-net-8gk47 --template '{{.status.initContainerStatuses}}' -n kube-system

# init container
kubectl describe pod <pod-name> -o yaml
    kubectl describe pod weave-net-8gk47 -n kube-system -o yaml

kubectl describe pod <pod-name> -n kube-system -o yaml | grep 'Image ID:'
    kubectl describe pod weave-net-8gk47 -n kube-system -o yaml | grep weave-npc

kubectl logs <pod-name> -c <init-container-2> -o yaml
    kubectl logs weave-net-8gk47 -c <init-container-2> -o yaml

# To access one of the containers in the pod, enter the following command
kubectl exec -it pod_name -c container_name bash
kubectl exec -n kube-system weave-net-8gk47 -c weave -- /home/weave/weave --local status

# #########################################


# Можно попробовать продлолжить от сюда:
https://github.com/kubernetes/kubernetes/issues/34101
https://github.com/weaveworks/weave/issues/3636

Dec 26 13:18:50 master kubelet[6563]: E1226 13:18:50.857635    6563 run.go:74 "command failed" err="failed to validate kubelet flags: the container runtime "command failed" err="failed to validate kubelet flags: the container runtime endpoint address was not specified or empty, use --container-runtime-endpoint to set"

Dec 26 13:19:07 master kubelet[6623]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.27. Image garbage collector will get sandbox>
Dec 26 13:19:07 master kubelet[6623]: I1226 13:19:07.954211    6623 server.go:198] "--pod-infra-container-image will not be pruned by the image garbage colle>
Dec 26 13:19:07 master kubelet[6623]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.27. Image garbage collector will get sandbox>

