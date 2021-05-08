#!/bin/bash

echo "[TASK 1] Pull required containers"
kubeadm config images pull >/dev/null 2>&1

echo "[TASK 2.1] Update ClusterConfiguration"
sudo rm -f /etc/kubernetes/kubeadm-config.yml
cat >>/etc/kubernetes/kubeadm-config.yml<<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: 1.19.0
clusterName: example
controlPlaneEndpoint: "172.16.16.100"
imageRepository: k8s.gcr.io
apiServer:
  certSANs:  #Additional hostnames or IP addresses that should be added to the Subject Alternate Name section for the certificate that the API Server will use. If you expose the API Server through a load balancer and public DNS you could specify this with
  - 127.0.0.1
  - 172.16.16.100
  - "k8smaster.example.com"
  extraVolumes:
  - name: "example-volume"
    hostPath: "/var/log/kubernetes/example"
    mountPath: "/etc/kubernetes/example"
    readOnly: false
    pathType: DirectoryOrCreate
  timeoutForControlPlane: 4m0s
certificatesDir: /etc/kubernetes/pki
controllerManager:
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
networking:
  dnsDomain: cluster.local
  podSubnet: 192.168.0.0/16 # --pod-network-cidr
scheduler:
  extraArgs:
    feature-gates: "TTLAfterFinished=true"
    bind-address: 0.0.0.0
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
FeatureGates:
  TTLAfterFinished: true
EOF

echo "[TASK 2.1] Initialize Kubernetes Cluster"
kubeadm init --config /etc/kubernetes/kubeadm-config.yml

echo "[TASK 3] Deploy Calico network"
# kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml >/dev/null 2>&1
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://gitlab.com/samir-romdhani/networking-utils/-/raw/master/kube-flannel2.yml >/dev/null 2>&1
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://gitlab.com/samir-romdhani/networking-utils/-/raw/master/calico.yaml >/dev/null 2>&1

echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null
