# References:
# https://medium.com/devops-dudes/step-by-step-process-to-deploy-kubernetes-on-your-raspberry-pis-61abed475cd8
# https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi#5-master-node-and-leaf-nodes
# https://microk8s.io/docs
# If ufw is enabled microk8s will fail unless you run the line below.

snap info microk8s && \
snap install microk8s --classic --channel=1.20/stable && \
microk8s.status --wait-ready && \
usermod -a -G microk8s $1 && \
chown -f -R $1 ~/.kube && \
echo $'alias kubectl=\'microk8s kubectl\'\nalias helm3=\'microk8s helm3\'' > /etc/profile.d/microk8s_aliases.sh && \
sudo ufw allow in on vxlan.calico && sudo ufw allow out on vxlan.calico
