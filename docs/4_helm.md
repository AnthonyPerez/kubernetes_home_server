# Helm

We will manage helm outside of microk8s to be able to use the latest version.

- `snap install helm --classic`
- Point helm to the cluster with
```
mkdir /etc/microk8s
microk8s config > /etc/microk8s/microk8s.conf
export KUBECONFIG=/etc/microk8s/microk8s.conf
```

You can either add `export KUBECONFIG=/etc/microk8s/microk8s.conf` to the bash profile or run it every time helm is used.

Also note that whenever the microk8s config changes you will need to re-run the `microk8s config > /etc/microk8s/microk8s.conf` command to update the configuation. This can be setup in a cron job or manually re-run as necessary (i.e. before using helm when the configuration has changed).

It's also possible to directly set the `KUBECONFIG` env variable to `/var/snap/microk8s/current/credentials/client.config` which is where microk8s stores the kubectl config file. e.g. `export KUBECONFIG=/var/snap/microk8s/current/credentials/client.config`
