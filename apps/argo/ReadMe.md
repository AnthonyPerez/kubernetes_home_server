# Argo

## Install

You can find the sources of the install file [here](https://github.com/argoproj/argo-workflows/releases/tag/v3.1.14). There is an alternative version of the manifest that allows execution in any namespace.

From the `install` folder run:
- `kubectl apply -f argo_namespace.yaml`
- `kubectl apply -n argo -f argo_v3.1.14_namespace-install.yaml`
- `kubectl apply -n argo -f argo_configmap.yaml` Override the argo configmap which is the recommend way to configure argo.
- `kubectl apply -n argo -f argo_server_service.yaml` Override the argo server service with our own that is load balanced.
- `bash install_cli_local.sh`  -- Note that this installs the argo CLI locally, it does nothing to your cluster. It's also configured for the ARM64 architecture. Find the appropriate binary on [the github release page](https://github.com/argoproj/argo-workflows/releases/tag/v3.1.14). See more info [here](https://argoproj.github.io/argo-workflows/cli/) including connecting and setting up TLS.

For workflow configuration see [here](https://argoproj.github.io/argo-workflows/configure-artifact-repository/) and [here](https://argoproj.github.io/argo-workflows/workflow-controller-configmap/).


Note that the `-n argo` part of the command must match your namespace.
Some cleanup has been setup in the workflow controller configmap. See [here](https://argoproj.github.io/argo-workflows/cost-optimisation/) for more info.

## Uninstall

More verbose than necessary but this communicates what it happening.

From the `install` folder run:
- `kubectl delete -n argo -f argo_configmap.yaml`
- `kubectl delete -n argo -f argo_v3.1.14_namespace-install.yaml`
- `kubectl delete -f argo_namespace.yaml`

## Test

Two test workflows are provided in the `test` folder. They are copied directly from the public argo examples. run them in the `test` folder as follows:

- `argo list`
- `argo submit dag-coinflip.yaml`
- `argo watch @latest`
- `argo submit map-reduce.yaml`
- `argo watch @latest`
- `argo list`
