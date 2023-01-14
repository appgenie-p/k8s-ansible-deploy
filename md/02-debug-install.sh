ssh vagrant@192.168.1.188 -i ~/.vagrant.d/insecure_private_key
ansible all -m ping -i ansible_hosts.cfg

# https://github.com/devopsgroup-io/vagrant-hostmanager

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
    # v1.26
    # https://blog.kubesimplify.com/kubernetes-126

cat /etc/containerd/config.toml | grep SystemdCgroup
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' \
    /etc/containerd/config.toml

# Установка кластера
sudo kubeadm init --apiserver-advertise-address=10.0.1.9 \
    --pod-network-cidr=10.32.0.0/12 --kubernetes-version=v1.26.0 \
    --cri-socket unix:///run/containerd/containerd.sock \
    --upload-certs

sudo export KUBECONFIG=/etc/kubernetes/admin.conf

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get pod -n kube-system

# Network Add-ons
    # https://www.weave.works/docs/net/latest/kubernetes/kube-addon/

# Install CNI Add-on Weave Net
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# Install CNI Add-on Flannel
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml

# Подключить worker nodes
kubeadm token create --print-join-command
    kubeadm join 10.0.2.15:6443 --token u048fl.9l7zst4i98s4y4al --discovery-token-ca-cert-hash \
        sha256:2dc6aac05cd4e49d11ae33c99b08aea6becc6a99daa375cc3ee0c052aa904428

kubectl get pod -n kube-system

###################################################################
# Дебаг проблем с кластером
# https://kubernetes.io/docs/tasks/debug/debug-application/
# https://sematext.com/blog/tail-kubernetes-logs/

# Проверить статус кластера
kubectl get pod -n kube-system
kubectl cluster-info
kubectl version --short -o yaml
kubectl config view
kubectl get svc
kubectl get namespace       # должен быть podSubnet
kubectl -n kube-system get cm kubeadm-config -o yaml
kubectl get node -o wide

# Получит события кластера
kubectl get events

# Удостовериться, что API прослушивается
sudo netstat -pnlt | grep 6443
# tcp6 0 0 :::6443 :::* LISTEN 4546/kube-apiserver

# Отобарзить состояние системных подов
kubectl get pod -n kube-system -o wide

# Отобразить логи CRI - убедиться что все поды запущены без ошибок
sudo crictl ps -a
sudo crictl ps -a -v
sudo crictl logs
sudo crictl logs <problem-container-ID>
    sudo crictl logs ddb989960587a

# Отобразить логи kubelet
sudo journalctl -u kubelet --no-pager
sudo journalctl -xu kubelet --no-pager -S 2019-12-30 > kubelet.log

# Отобразить логи containerd
sudo containerd version

# Получить информацию о поде
kubectl get pod -n kube-system -o wide

kubectl get pod <pod-name> -n kube-system [-o wide][-o yaml]
    kubectl get pod weave-net-8gk47 -n kube-system -o wide
    kubectl get pod weave-net-8gk47 -n kube-system -o yaml

kubectl describe pod <pod-name> -n kube-system
    kubectl describe pod weave-net-8gk47 -n kube-system

# Получить перечень контейнеров в поде:
kubectl get pods <pod-name> -o jsonpath='{.spec.containers[*].name}' -n kube-system
# or
kubectl describe pod -n kube-system <pod-name> | grep 'Image:'

# Статус контейнера
kubectl get pod <pod-name> --template '{{.status.initContainerStatuses}}' -n kube-system
    kubectl get pod weave-net-8gk47 --template '{{.status.initContainerStatuses}}' -n kube-system

# Посмотреть логи пода и контейнеров в нем
kubectl logs pod-name [--since=2h] [--tail=10]

kubectl logs -n kube-system <pod-name>
    kubectl logs -n kube-system  weave-net-8gk47  

kubectl logs -n kube-system <pod-name> -c <container-name>
    kubectl logs -n kube-system  weave-net-8gk47 -c weave-npc
    kubectl logs -n kube-system  weave-net-8gk47 -c weave-kube

kubectl logs -n kube-system <pod-name> -c <container-name> --previous=true [-p]
    kubectl logs -n kube-system weave-net-8gk47 -c weave-npc --previous=true
    kubectl logs -n kube-system weave-net-8gk47 -c weave-kube -p
    kubectl logs -n kube-system weave-net-8gk47 -c weave-init -p

# To access one of the containers in the pod, enter the following command
kubectl exec -it pod_name -c container_name bash
kubectl exec -n kube-system weave-net-8gk47 -c weave -- /home/weave/weave --local status

# #########################################

# Проверка работоспособности
kubectl run test1 --image=nginx
kubectl run test2 --image=nginx
kubectl expose pod nginx --type=NodePort --port 80
kubectl get pods
kubectl get svc nginx

# унижтожение ноды кластера
sudo kubeadm reset -f &&
rm $HOME/.kube/config &&
sudo rm /etc/cni/net.d

sudo kubeadm config images pull --image-repository=registry.k8s.io \
    --cri-socket unix:///run/containerd/containerd.sock

k create deployment my-deployment --image=nginx:1.20 --port=80 \
    --replicas=3 --dry-run=client --output=yaml > my-deployment.yaml

curl 10.108.123.23:8080
curl nginx-service:8080

kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment web --type=NodePort --port=8080
kubectl get service web
minikube service web --url