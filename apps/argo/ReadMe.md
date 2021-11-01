# Argo

## Install

You can find the sources of the install file [here](https://github.com/argoproj/argo-workflows/releases/tag/v3.1.14). There is an alternative version of the manifest that allows execution in any namespace.

The installation of argo is sensitive to the installation of minio. The configmap and minio-credentials secret will need to be adjusted if the minio installation changes.

From the `install` folder run:
- Create a minio bucket named `argo`. There are a number of ways to do this, I did it through the minio console.
- `kubectl apply -f argo_namespace.yaml`
- Create the minio credentials as follows (the secret name is set in the configmap)

```
kubectl create secret generic -n argo minio-credentials \
    --from-literal=accesskey=$(kubectl get secret -n minio minio-access-secret -o jsonpath="{.data.accesskey}" | base64 --decode) \
    --from-literal=secretkey=$(kubectl get secret -n minio minio-access-secret -o jsonpath="{.data.secretkey}" | base64 --decode)
```

- `kubectl apply -n argo -f argo_v3.1.14_namespace-install.yaml`
- `kubectl apply -n argo -f argo_configmap.yaml` Override the argo configmap which is the recommend way to configure argo.
- `kubectl apply -n argo -f argo_server_service.yaml` Override the argo server service with our own that is load balanced.
- `bash install_cli_local.sh`  -- Note that this installs the argo CLI locally, it does nothing to your cluster. It's also configured for the ARM64 architecture. Find the appropriate binary on [the github release page](https://github.com/argoproj/argo-workflows/releases/tag/v3.1.14). See more info [here](https://argoproj.github.io/argo-workflows/cli/) including connecting and setting up TLS.

For workflow configuration see [here](https://argoproj.github.io/argo-workflows/configure-artifact-repository/), [here](https://argoproj.github.io/argo-workflows/workflow-controller-configmap/), and [here](https://argoproj.github.io/argo-workflows/workflow-controller-configmap.yaml). In particular pay attention to the [workflow executors](https://argoproj.github.io/argo-workflows/workflow-executors)

Note that the `-n argo` part of the command must match your namespace.
Some cleanup has been setup in the workflow controller configmap. See [here](https://argoproj.github.io/argo-workflows/cost-optimisation/) for more info.

## Debugging

- All workflows must execute under the argo service account. Workflows may need more permissions than the role provides. Currently, the role is was editted from the original source to include additional permissions for pods/log which is necessary for the PNS executor.

- Argo relies on kubernetes logs. If there are any issues with kubernetes logs (e.g. you don't see the log you expect when your run `kubectl log -n argo pod/pod-name`) then argo will fail to pass outputs due to that issue.

## Login to UI

Install the command line client. Grab your client token with `ARGO_SERVER=192.168.86.201:9004 KUBECONFIG=/etc/microk8s/microk8s.conf argo --secure auth token`. Modify the environment variables as necessary for your configuration, they may already be set in the environment.

In your browser, navigate to [https://192.168.86.201:9004](https://192.168.86.201:9004) (you may have configured a different address, see `argo_server_service.yaml`).

## Uninstall

More verbose than necessary but this communicates what it happening.

From the `install` folder run:
- `kubectl delete -n argo -f argo_server_service.yaml`
- `kubectl delete -n argo -f argo_configmap.yaml`
- `kubectl delete -n argo -f argo_v3.1.14_namespace-install.yaml`
- `kubectl delete secret -n argo minio-credentials`
- `kubectl delete -f argo_namespace.yaml` Deleting the name space will delete all resources in that namespace, so this is the only necessary command.

To delete the Argo artifact data, delete the argo bucket in minio.

## Test

Two test workflows are provided in the `test` folder. They are copied directly from the public argo examples. run them in the `test` folder as follows:

Make sure environment variables are set correctly:

- `export ARGO_SERVER=192.168.86.201:9004`
- `export KUBECONFIG=/etc/microk8s/microk8s.conf`

or

- `alias argo="ARGO_SERVER=192.168.86.201:9004 KUBECONFIG=/etc/microk8s/microk8s.conf argo --secure"`

- `argo --secure list`
- `argo --secure submit dag-coinflip.yaml`
- `argo --secure watch @latest`
- `argo --secure submit map-reduce.yaml`
- `argo --secure watch @latest`
- `argo --secure list`
