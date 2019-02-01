#!/bin/bash

# bash genconf-flannel.sh <etcd1_ip> <etcd2_ip> <etcd3_ip>

cat > flannel.service <<EOF
[Unit]
Description=Flannel Overlay
Documentation=https://github.com/coreos/flannel/

[Service]
ExecStart=/usr/bin/flanneld \
  --etcd-cafile=/var/lib/kubernetes/ca.pem \
  --etcd-endpoints=https://${1}:2379,https://${2}:2379,https://${3}:2379

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
