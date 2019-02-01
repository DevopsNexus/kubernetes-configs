#!/bin/bash

# bash etcd.conf.sh <etcd1_ip>  <etcd2_ip> <etcd3_ip> 

cat > ${1}.etcd.conf <<EOF
ETCD_NAME="${1}"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://${1}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${1}:2379,https://localhost:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${1}:2380"
ETCD_INITIAL_CLUSTER="${1}=https://${1}:2380,${2}=https://${2}:2380,${3}=https://${3}:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-0"
ETCD_ADVERTISE_CLIENT_URLS="https://${1}:2379"
ETCD_CERT_FILE="/etc/etcd/kubernetes.pem"
ETCD_KEY_FILE="/etc/etcd/kubernetes-key.pem"
ETCD_TRUSTED_CA_FILE="/etc/etcd/ca.pem"
ETCD_PEER_CERT_FILE="/etc/etcd/kubernetes.pem"
ETCD_PEER_KEY_FILE="/etc/etcd/kubernetes-key.pem"
ETCD_PEER_TRUSTED_CA_FILE="/etc/etcd/ca.pem"
EOF

cat > ${2}.etcd.conf <<EOF
ETCD_NAME="${2}"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://${2}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${2}:2379,https://localhost:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${2}:2380"
ETCD_INITIAL_CLUSTER="${1}=https://${1}:2380,${2}=https://${2}:2380,${3}=https://${3}:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-0"
ETCD_ADVERTISE_CLIENT_URLS="https://10.139.68.214:2379"
ETCD_CERT_FILE="/etc/etcd/kubernetes.pem"
ETCD_KEY_FILE="/etc/etcd/kubernetes-key.pem"
ETCD_TRUSTED_CA_FILE="/etc/etcd/ca.pem"
ETCD_PEER_CERT_FILE="/etc/etcd/kubernetes.pem"
ETCD_PEER_KEY_FILE="/etc/etcd/kubernetes-key.pem"
ETCD_PEER_TRUSTED_CA_FILE="/etc/etcd/ca.pem"
EOF

cat > ${3}.etcd.conf <<EOF
ETCD_NAME="${3}"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://${3}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${3}:2379,https://localhost:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${3}:2380"
ETCD_INITIAL_CLUSTER="${1}=https://${1}:2380,${2}=https://${2}:2380,${3}=https://${3}:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-0"
ETCD_ADVERTISE_CLIENT_URLS="https://${3}:2379"
ETCD_CERT_FILE="/etc/etcd/kubernetes.pem"
ETCD_KEY_FILE="/etc/etcd/kubernetes-key.pem"
ETCD_TRUSTED_CA_FILE="/etc/etcd/ca.pem"
ETCD_PEER_CERT_FILE="/etc/etcd/kubernetes.pem"
ETCD_PEER_KEY_FILE="/etc/etcd/kubernetes-key.pem"
ETCD_PEER_TRUSTED_CA_FILE="/etc/etcd/ca.pem"
EOF
