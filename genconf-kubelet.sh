#!/bin/bash

# bash genconf-kublet.sh <apiserver_ip> <node_ip>

## Kubelet config generator
kubectl config set-cluster demo-cluster \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${1}:6443 \
    --kubeconfig=${2}.kubeconfig

kubectl config set-credentials system:node:${2} \
    --client-certificate=${2}.pem \
    --client-key=${2}-key.pem \
    --embed-certs=true \
    --kubeconfig=${2}.kubeconfig

kubectl config set-context default \
    --cluster=demo-cluster \
    --user=system:node:${2} \
    --kubeconfig=${2}.kubeconfig

kubectl config use-context default --kubeconfig=${2}.kubeconfig

cat <<EOF | tee ${2}.kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${2}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${2}-key.pem"
EOF

cat <<EOF | tee ${2}.kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=docker \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --cni-conf-dir=/var/lib/kubernetes/cni/net.d/ \\
  --register-node=true \\
  --hostname-override=${2} \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

## Kubeproxy config generator
kubectl config set-cluster demo-cluster \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${1}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
    --cluster=demo-cluster \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
