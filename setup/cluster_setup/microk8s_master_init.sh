# References:
# https://medium.com/devops-dudes/step-by-step-process-to-deploy-kubernetes-on-your-raspberry-pis-61abed475cd8
# https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi#5-master-node-and-leaf-nodes
# https://microk8s.io/docs

# microk8s enable portainer && \ # Not worth the resources at the moment.

microk8s enable rbac && \

microk8s enable dns && \ 
microk8s enable dashboard && \ 
microk8s enable ingress && \ 
microk8s enable helm && \ 
microk8s enable helm3 && \ 
microk8s enable storage && \ 
microk8s enable metallb:192.168.86.200-192.168.86.202 && \
microk8s enable metrics-server && \ 
microk8s enable registry && \ 
microk8s.kubectl get all --all-namespaces
