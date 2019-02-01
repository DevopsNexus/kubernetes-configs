
# K8s Training Commands

## Basic Setup on all servers
**&gt;** yum install -y vim git wget yum-utils device-mapper-persistent-data lvm2

## Install docker
**&gt;** yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
**&gt;** yum install docker-ce-18.06.1.ce
**&gt;** systemctl start docker

## Get Kubectl
**&gt;&gt;** wget https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl
**&gt;&gt;** chmod +x kubectl
**&gt;&gt;** mv kubectl /usr/bin

## Minikube
wget https://github.com/kubernetes/minikube/releases/download/v0.33.1/minikube-linux-amd64
mv minikube-linux-amd64 /usr/bin/
chmod +x /usr/bin/minikube
minikube start --vm-driver none

## Basic Kubectl commands (smoke test)
kubectl get nodes
kubectl run nginx --image=nginx
kubectl get pods
kubectl describe pod <pod>
kubectl expose deployment nginx --port 80 --type NodePort
kubectl get svc

## Get Kubernetes binaries
**&gt;&gt;** wget https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kube-apiserver 
**&gt;&gt;** wget https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kube-controller-manager
**&gt;&gt;** wget https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kube-scheduler
**&gt;&gt;** wget https://github.com/coreos/flannel/releases/download/v0.10.0/flanneld-amd64
**&gt;&gt;** mv flanneld-amd64 flanneld
**&gt;&gt;** chmod +x kube-apiserver kube-controller-manager kube-scheduler flanneld
**&gt;&gt;** mv kube-apiserver kube-controller-manager kube-scheduler flanneld /usr/bin/

## Generate Kubernetes Config
**&gt;** git clone **<config_repo>**
**&gt;** bash gencert-kubernetes.sh 
**&gt;** bash gencert-kubeapiserver.sh **<apiserver_ip_csv>**
**&gt;** bash genconf-kubernetes.sh
**&gt;** scp *.pem root@**<server_IP>**
**&gt;** for ip in **<server2_ip> <server3_ip>**
do
 &nbsp;&nbsp;  scp *.pem *.kubeconfig root@\${ip}:k8s-conf/
done

**&gt;** for ip in **<etcd1_ip>  <etcd2_ip> <etcd3_ip>**
do
 &nbsp;&nbsp; scp \${ip}.kube-apiserver.service root@\${ip}:/etc/systemd/system/kube-apiserver.service
 &nbsp;&nbsp;    scp kube-controller-manager.service kube-scheduler.service root@\${ip}:/etc/systemd/system/
done

**&gt;&gt;** cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem kube-controller-manager.kubeconfig kube-scheduler.kubeconfig /var/lib/kubernetes/
**&gt;&gt;** mkdir -p /etc/kubernetes/config/
**&gt;&gt;** cp kube-scheduler.yaml /etc/kubernetes/config/kube-scheduler.yaml


## Setup etcd
**&gt;&gt;** yum install -y etcd
**&gt;** cd **<config_repo>**
**&gt;** bash etcd.conf.sh **<etcd1_ip>  <etcd2_ip> <etcd3_ip>**

**&gt;** for ip in **<etcd1_ip>  <etcd2_ip> <etcd3_ip>**
do 
 &nbsp;&nbsp; scp \${ip}.etcd.conf  root@\${ip}:/etc/etcd/etcd.conf
&nbsp;&nbsp;  scp kubernetes.pem kubernetes-key.pem ca.pem /etc/etcd/
done

**&gt;&gt;** systemctl restart etcd


## Configure flannel

**&gt;&gt;** mkdir /var/lib/kubernetes
**&gt;&gt;** bash genconf-flannel.sh <etcd1_ip> <etcd2_ip> <etcd3_ip>
**&gt;&gt;** cp flannel.service /etc/systemd/system/
**&gt;&gt;** cd **<config_repo>**
**&gt;&gt;** cp ca.pem /var/lib/kubernetes
**&gt;** etcdctl --endpoints=https://127.0.0.1:2379 --ca-file=/etc/etcd/ca.pem set /coreos.com/network/config '{"Network": "10.200.0.0/16", "SubnetLen":24, "Backend": {"Type": "vxlan"}}'

## Start Kubernetes
**&gt;&gt;** systemctl daemon-reload
**&gt;&gt;** systemctl restart flannel kube-apiserver kube-controller-manager kube-scheduler
**&gt;&gt;** kubectl get componentstatuses --kubeconfig admin.kubeconfig


## Setup Kubelet
yum install -y socat conntrack ipset yum-utils device-mapper-persistent-data lvm2 vim git wget
wget   https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl   https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kube-proxy   https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubelet
Setup Flannel
mkdir -p /opt/cni/bin/; cd /opt/cni/bin/
wget https://github.com/containernetworking/plugins/releases/download/v0.7.4/cni-plugins-amd64-v0.7.4.tgz
tar -xzvf cni-plugins-amd64-v0.7.4.tgz
mkdir -p /var/lib/kubernetes/cni/net.d
cd **<config_repo>**

cp 10-flannel.conf /var/lib/kubernetes/cni/net.d/10-flannel.conf

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-18.06.1.ce
bash gencert-kubelet.sh **<kubelet_ip>**
bash genconf-kubelet.sh **<apiserver_ip> <kubelet_ip>**
mkdir /var/lib/kubelet/
mv **<kubelet_ip>**-key.pem **<kubelet_ip>**.pem /var/lib/kubelet/
mv **<kubelet_ip>**.kubeconfig /var/lib/kubelet/kubeconfig
mv **<kubelet_ip>**.kubelet-config.yaml /var/lib/kubelet/kubelet-config.yaml 
mv **<kubelet_ip>**.kubelet.service /etc/systemd/system/kubelet.service
mkdir /var/lib/kube-proxy/
mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
mv kube-proxy-config.yaml /var/lib/kube-proxy/kube-proxy-config.yaml
mv kube-proxy.service /etc/systemd/system/kube-proxy.service


systemctl start docker
systemctl daemon-reload
systemctl restart flannel kube-apiserver kube-controller-manager kube-scheduler
