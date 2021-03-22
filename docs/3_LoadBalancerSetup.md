# Load Balancer Setup

Assuming that the cluster setup was followed as described in the previous steps (i.e. that metallb is enabled), all that is necessary is to run `kubectl apply -f setup/load_balancer/ingress_service.yaml`. Then you can run `microk8s kubectl -n ingress get svc` and use the listed external IP and ports to access your cluster.

If you run `microk8s kubectl -n ingress get svc` before creating the service above and it tells you that a service already exists, then something has diverged from the expectations of this setup document. You may already have load balancing set up. This document assumes that the microk8s ingress and metallb addons have been enabled.

You can use the `setup/load_balancer/test_loadbalancer.yaml` manifest to quickly test the load balancer. After applying, navigating to `https://<you load balancer service's IP address>/testlb` should show the welcome to NGINX page.

## Sources

1. https://jonathangazeley.com/2020/12/30/load-balancing-ingress-with-metallb-on-microk8s/
2. https://microk8s.io/docs/addon-metallb
