
## Kubernetes 1.19.0 with vagrant

# k8smaster  
- sudo passwd root

# home
scp root@k8smaster.example.com:/etc/kubernetes/admin.conf .kube/conf
export KUBECONFIG=.kube/conf

## KAFKA Integration
