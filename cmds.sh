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
    # https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-20-04

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
    apiVersion: v1
    # data:
    #   ClusterConfiguration: |
    #     apiServer:
    #       extraArgs:
    #         authorization-mode: Node,RBAC
    #       timeoutForControlPlane: 4m0s
    #     apiVersion: kubeadm.k8s.io/v1beta3
    #     certificatesDir: /etc/kubernetes/pki
    #     clusterName: kubernetes
    #     controllerManager: {}
    #     dns: {}
    #     etcd:
    #       local:
    #         dataDir: /var/lib/etcd
    #     imageRepository: k8s.gcr.io
    #     kind: ClusterConfiguration
    #     kubernetesVersion: v1.22.17
    #     networking:
    #       dnsDomain: cluster.local
    #       podSubnet: 10.244.0.0/16
    #       serviceSubnet: 10.96.0.0/12
    #     scheduler: {}
    # kind: ConfigMap
    # metadata:
    #   creationTimestamp: "2022-12-27T13:36:45Z"
    #   name: kubeadm-config
    #   namespace: kube-system
    #   resourceVersion: "210"
    #   uid: 016a4fc4-0dba-49ce-8168-3b3d167a5927
kubectl get svc
    # NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
    # kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   50m
kubectl get namespace
sudo netstat -pnlt | grep 6443
kubectl config view
    apiVersion: v1
    # clusters:
    # - cluster:
    #     certificate-authority-data: DATA+OMITTED
    #     server: https://10.0.1.9:6443
    #   name: kubernetes
    # contexts:
    # - context:
    #     cluster: kubernetes
    #     user: kubernetes-admin
    #   name: kubernetes-admin@kubernetes
    # current-context: kubernetes-admin@kubernetes
    # kind: Config
    # preferences: {}
    # users:
    # - name: kubernetes-admin
    #   user:
    #     client-certificate-data: REDACTED
    #     client-key-data: REDACTED
kubectl get node -o wide
kubectl get pod -n kube-system -o wide

# Network Add-ons
    # https://www.weave.works/docs/net/latest/kubernetes/kube-addon/
    # https://www.weave.works/docs/net/latest/install/installing-weave/

# Install CNI Add-on Weave Net
wget https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubectl apply -f weave-daemonset-k8s.yaml

# Подключить worker nodes
kubeadm token create --print-join-command
    kubeadm join 10.0.2.15:6443 --token u048fl.9l7zst4i98s4y4al --discovery-token-ca-cert-hash \
        sha256:2dc6aac05cd4e49d11ae33c99b08aea6becc6a99daa375cc3ee0c052aa904428

###################################################################
# Дебаг проблем с кластером
# https://kubernetes.io/docs/tasks/debug/debug-application/
# https://sematext.com/blog/tail-kubernetes-logs/

kubectl cluster-info dump
sudo netstat -pnlt | grep 6443
# tcp6 0 0 :::6443 :::* LISTEN 4546/kube-apiserver

# Отобразить логи kubelet
sudo journalctl -u kubelet --no-pager
journalctl -xeu kubelet
sudo journalctl -xu kubelet --no-pager
sudo journalctl -xu kubelet --no-pager -S 2019-12-30 > kubelet.log

# Получит события кластера
kubectl get events

# https://github.com/weaveworks/weave/issues/3437
# https://stackoverflow.com/questions/61278005/weave-crashloopbackoff-on-fresh-ha-cluster

# !!! Отобразить логи CRI
sudo crictl ps -a
sudo crictl logs

sudo crictl logs <problem-container-ID>
    sudo crictl logs ddb989960587a

sudo containerd version
kubectl version --short -o yaml

# Получить информацию о поде
kubectl get pod <pod-name> -n kube-system -o wide
    kubectl get pod weave-net-8gk47 -n kube-system -o wide
    kubectl get pod weave-net-8gk47 -n kube-system -o yaml

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
    kubectl logs -n kube-system weave-net-8gk47 -c weave-kube -p
    kubectl logs -n kube-system weave-net-8gk47 -c weave-init -p
# Статус контейнера
kubectl get pod <pod-name> --template '{{.status.initContainerStatuses}}' -n kube-system
    kubectl get pod weave-net-8gk47 --template '{{.status.initContainerStatuses}}' -n kube-system

# Логи контейренов
kubectl describe pod <pod-name>
    kubectl describe pod -n kube-system weave-net-8gk47

kubectl logs <pod-name> -c <init-container-2>
    kubectl logs weave-net-8gk47 -n kube-system --all-containers=true
    kubectl logs weave-net-8gk47 -n kube-system -c weave-npc

# To access one of the containers in the pod, enter the following command
kubectl exec -it pod_name -c container_name bash
kubectl exec -n kube-system weave-net-8gk47 -c weave -- /home/weave/weave --local status

# #########################################