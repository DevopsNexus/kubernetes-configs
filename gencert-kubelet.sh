#!/bin/bash

# bash gencert-node.sh <kubelet_ip>

cat > ${1}-csr.json <<EOF
{
  "CN": "system:node:${1}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${1} \
  -profile=kubernetes \
  ${1}-csr.json | cfssljson -bare ${1}
