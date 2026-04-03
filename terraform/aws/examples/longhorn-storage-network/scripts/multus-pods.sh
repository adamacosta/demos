#!/bin/sh

kubectl create -f - <<EOF
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: macvlan-net0
  namespace: kube-system
spec: 
  config: '{
    "cniVersion": "1.0.0",
    "plugins": [
      {
        "type": "macvlan",
        "master": "ens6",
        "mode": "bridge",
        "ipam": {
          "type": "host-local",
          "ranges": [
            [
              { "subnet": "10.90.0.0/16" }
            ]
          ]
        }
      }
    ]
  }'
EOF

kubectl create -f - <<EOF
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: ptp-net0
  namespace: kube-system
spec: 
  config: '{
    "cniVersion": "1.0.0",
    "plugins": [
      {
        "type": "ptp",
        "ipMasq": true,
        "ipam": {
          "type": "host-local",
          "ranges": [
            [
              { "subnet": "10.100.0.0/24" }
            ]
          ]
        }
      }
    ]
  }'
EOF

kubectl create -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  annotations:
    k8s.v1.cni.cncf.io/networks: kube-system/ptp-net0
  creationTimestamp: null
  name: ptp-net0
  namespace: kube-system
spec:
  containers:
  - command:
    - sleep
    - inf
    image: wbitt/network-multitool
    name: nettool
    resources: {}
EOF

kubectl create -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: net0
  namespace: kube-system
spec:
  containers:
  - command:
    - sleep
    - inf
    image: wbitt/network-multitool
    name: nettool
    resources: {}
EOF