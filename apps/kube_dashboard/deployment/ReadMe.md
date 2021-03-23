# Deploying the Kubernetes Dashboard

1. Enable the dashboard in microk8s if it is not already (manual installation will not be covered in this guide).
2. Create the ingress service and readonly dhasboard account by running `kubectl apply -f apps/kube_dashboard/deployment/dashboard_ingress_and_user.yaml`.
3. Get your token by running `bash apps/kube_dashboard/deployment/get_token.sh`
4. Log in to the dashboard at using the token. See `apps/ReadMe.md` for what to type into your browser's address bar.

## Sources

* [With a certificate, but out of date](https://jonathangazeley.com/2020/09/16/exposing-the-kubernetes-dashboard-with-an-ingress/)
* [For user role settings](https://blog.kube-mesh.io/read-only-kubernetes-dashboard/)