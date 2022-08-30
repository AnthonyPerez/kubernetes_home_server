# Deploying the container registry

## Prerequisites

This setup assumes you have a load balancer already setup.

The helm chart copied here is a fork, I do not take credit. See the link below.

## Helm Chart Modifications

- cronjob.yaml
    - `apiVersion: batch/v1` > `apiVersion: batch/v1beta1` Due to my kubernetes version.
- deployment.yaml
    - Added an environment variable named `REGISTRY_STORAGE_S3_SKIPVERIFY` with a value of `"true"` to skip TLS verification for minio.

## Deployment Steps

The installation of the container registry is sensitive to the installation of minio. The configmap and minio-credentials secret will need to be adjusted if the minio installation changes.

1. From the `install` folder run:
- `kubectl apply -f cr_namespace.yaml`

For minio access run the following:

- Create a minio bucket named `container-registry`. There are a number of ways to do this, I did it through the minio console.
- Create the minio credentials as follows (the secret name is set in the configmap)

```
kubectl create secret generic -n container-registry minio-credentials \
    --from-literal=s3AccessKey=$(kubectl get secret -n minio minio-access-secret -o jsonpath="{.data.accesskey}" | base64 --decode) \
    --from-literal=s3SecretKey=$(kubectl get secret -n minio minio-access-secret -o jsonpath="{.data.secretkey}" | base64 --decode)
```

To use a PV/PVC for storage run the following:

- On node202 run `mkdir /mnt/hdd1/container_registry`
- `kubectl apply -n container-registry -f pv_pvc.yaml`

2. Run the following commands to generate the certificate for the container registry.

```
openssl req -subj '/CN=192.168.86.201' -addext "subjectAltName = IP:192.168.86.201" -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 10000 && \
kubectl create secret generic -n container-registry container-registry-tls \
    --from-file=tls.crt=cert.pem \
    --from-file=tls.key=key.pem && \
rm key.pem cert.pem
```

3. Create the username and password for the container-registry.

```
kubectl create secret generic -n container-registry container-registry-user-pass \
    --from-literal=user=$(uuidgen) \
    --from-literal=pass=$(uuidgen)
```

Run `apt install apache2-utils` to install `htpasswd`

```
kubectl create secret generic -n container-registry container-registry-htpasswd \
    --from-literal=htpasswd=$(htpasswd -nbB $(kubectl get secret -n container-registry container-registry-user-pass -o jsonpath="{.data.user}" | base64 --decode) $(kubectl get secret -n container-registry container-registry-user-pass -o jsonpath="{.data.pass}" | base64 --decode))
```

4. Deploy the helm chart. Run the following in the install directory. If using minio as the storage backend, make sure the replace all instances of `chart_values.yaml` with `chart_values_minio.yaml`.

- The `{x; y;} | cat > out.txt` command will combine the output of x and y separated by a newline in out.txt. The `chart_values.yaml` file is setup so the following command works to add the `htpasswd` field to the `secrets` field.
```
{ \
    cat chart_values.yaml; \
    echo "  htpasswd: "$(kubectl get secret -n container-registry container-registry-htpasswd -o jsonpath="{.data.htpasswd}" | base64 --decode); \
} \
| cat > updated_chart_values.yaml && \
helm install --namespace container-registry -f updated_chart_values.yaml container-registry ./helm_chart/ && \
rm updated_chart_values.yaml
```

If you get an error like `Error: INSTALLATION FAILED: Kubernetes cluster unreachable: Get "http://localhost:8080/version?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused` you may need to run `kubectl config view --raw > ~/.kube/config` followed by `chmod 600 ~/.kube/config`

- `kubectl get all -n container-registry`

5. Configure your nodes to allow pulling images from the newly created contrainer-registry.

First get your username and password: `echo "Username: "$(kubectl get secret -n container-registry container-registry-user-pass -o jsonpath="{.data.user}" | base64 --decode)" Password: "$(kubectl get secret -n container-registry container-registry-user-pass -o jsonpath="{.data.pass}" | base64 --decode)`.

For a quick test, navigate to the URL in your browser and provide the username and password to list the empty registry. Specifically, go to `http://IP:PORT/v2/_catalog`. If you have images, `/v2/IMAGE_NAME/tags/list`  can be used to list the tags.

#### Off cluster nodes

Setting up TLS access to the private registry will depend on your specific host. See the [instructions for your specific host](https://docs.docker.com/registry/insecure/#use-self-signed-certificates) for more details. The instructions below are for windows with docker desktop.

Grab needed files from your cert secret:

```
kubectl get secret -n container-registry container-registry-tls -o jsonpath="{.data.tls\.crt}" | base64 --decode > microk8s_user_private_registry.crt
```

Copy the `microk8s_user_private_registry.crt` file from the machine that ran the command above onto your local machine, then delete `microk8s_user_private_registry.crt` from the machine that created it. On windows, right click on the `microk8s_user_private_registry.crt` in File Explorer and install the certificate. When selecting a store, you can let the wizard choose automatically. Restart Docker. If you need to remove the certificate later, run `inetcpl.cpl` in a command prompt. This will open a window. In the window click content followed by certificates. Find and remove the certificate you added. If you are using WSL for windows you do NOT need to trust the certificates on windows, just on the ubuntu VM. You can skip these steps.

If you're using ubuntu for your docker building, specifically WSL for windows, you will need to trust the CA in the WSL VM. Copy the `microk8s_user_private_registry.crt` file to `/usr/local/share/ca-certificates` and run `sudo update-ca-certificates`. You should rename the file to be consistent with the file name for on cluster nodes but the file must end in `.crt`. This will also add a file to `/etc/ssl/certs/`. If you want to remove the cert you will need to remove both these files.

It's very odd but documented [here] that the client that is pushing for pulling against the registry also needs to trust the minio cert. IF you are using minio as the storage backend then repeat the steps above with the minio cert. Here is show you grab it: 

```
kubectl get secret -n minio tls-ssl-minio -o jsonpath="{.data.public\.crt}" | base64 --decode > microk8s_user_minio.crt
```

Run `docker login 192.168.86.201:9005` and follow the prompts. You may need to do this on the WSL VM when using windows.

Test as follows, replace IP_ADDRESS and PORT as appropriate.

```
docker image pull busybox && \
docker tag busybox:latest IP_ADDRESS:PORT/busybox:latest && \
docker push IP_ADDRESS:PORT/busybox:latest
```

Make sure you see the image data stored in the minio bucket and not an empty dir. The empty dir's data will be under a directory like `/var/snap/microk8s/common/var/lib/kubelet/pods/50ac91a0-50e9-4bbc-bd5b-1d54e393b308/volumes/kubernetes.io~empty-dir/data/docker`.

Resources:
- [Official Docker Resource 1](https://docs.docker.com/desktop/faqs/windowsfaqs/#how-do-i-add-custom-ca-certificates)
- [Official Docker Resource 2](https://docs.docker.com/engine/security/certificates/)
- [Official Docker Resource 3](https://docs.docker.com/registry/insecure/#use-self-signed-certificates)
- [x509: certificate relies on legacy Common Name field, use SANs or temporarily enable Common Name matching with GODEBUG=x509ignoreCN=0](https://stackoverflow.com/questions/68196502/failed-to-connect-to-a-server-with-golang-due-x509-certificate-relies-on-legacy)
    - Make sure you're including `-addext "subjectAltName = IP:IP_ADDRESS"`
- [x509: cannot validate certificate for 192.168.86.201 because it doesn't contain any IP SANs](https://serverfault.com/questions/611120/failed-tls-handshake-does-not-contain-any-ip-sans)
    - Make sure you're including `-addext "subjectAltName = IP:IP_ADDRESS"` and not `-addext "subjectAltName = DNS:IP_ADDRESS"`. The difference is the `IP:xxx.xxx.xxx.xxx` vs `DNS:xxx.xxx.xxx.xxx`.

#### On cluster nodes

Use `snap info microk8s` to determine your version of microk8s. The following will work for microk8s version 1.20.X

On each node run the following command to place the certificate file at the appropriate location (it must be in the `/etc/ssl/certs/` directory but the name does not matter). Note the extra command to trust the minio cert as well. That cert is only necessary when using minio as the storage backend:

```
kubectl get secret -n container-registry container-registry-tls -o jsonpath="{.data.tls\.crt}" | base64 --decode > /etc/ssl/certs/microk8s_user_private_registry.pem && \
kubectl get secret -n minio tls-ssl-minio -o jsonpath="{.data.public\.crt}" | base64 --decode > /etc/ssl/certs/microk8s_user_minio.crt
```

Reboot your node e.g. with the `reboot` command.

When pulling an image you will need to create a docker-registry secret similar to the command below. The secret should be used with the `imagePullSecrets` field in your k8s objects. An example for using this secret is given in the `test` directory.

```
kubectl create secret docker-registry \
    -n test-container-registry test-image-pull-secret \
    --docker-server="https://192.168.86.201:9005" \
    --docker-username=$(kubectl get secret -n container-registry container-registry-user-pass -o jsonpath="{.data.user}" | base64 --decode) \
    --docker-password=$(kubectl get secret -n container-registry container-registry-user-pass -o jsonpath="{.data.pass}" | base64 --decode)
```

To test your changes run the following from the test directory (assuming you pushed busybox from an off cluster node as described above):

```
kubectl apply -f test_cr_namespace.yaml && \
kubectl create secret docker-registry \
    -n test-container-registry test-image-pull-secret \
    --docker-server="https://192.168.86.201:9005" \
    --docker-username=$(kubectl get secret -n container-registry container-registry-user-pass -o jsonpath="{.data.user}" | base64 --decode) \
    --docker-password=$(kubectl get secret -n container-registry container-registry-user-pass -o jsonpath="{.data.pass}" | base64 --decode) && \
kubectl apply -n test-container-registry -f test_cr_deployment.yaml
```

Then run `kubectl get pods -n test-container-registry` and `kubectl describe pods -n test-container-registry test-busy-box-deployment-7c578b9f5d-4l8f2`, replacing the pod name appropriately. Make sure the image is pulled successfully. `kubectl logs -n test-container-registry test-busy-box-deployment-7c578b9f5d-4l8f2`

- [Microk8s Guide](https://microk8s.io/docs/registry-private)
    - Modifying the `/var/snap/microk8s/current/args/containerd-template.toml` file seemed to have no effect for me.
- [Containerd Guide](https://github.com/containerd/cri/blob/master/docs/registry.md#configure-registry-tls-communication)
- [The cert must be in the /etc/ssl/certs/ directory.](https://discuss.kubernetes.io/t/microk8s-cant-pull-image-from-a-private-registry-with-ssl-self-signed-certificate/11604/2)
- [DaemonSet Solution](https://stackoverflow.com/questions/53545732/how-do-i-access-a-private-docker-registry-with-a-self-signed-certificate-using-k)


## Update Chart Values

First dry run with

```
{ \
    cat chart_values.yaml; \
    echo "  htpasswd: "$(kubectl get secret -n container-registry container-registry-htpasswd -o jsonpath="{.data.htpasswd}" | base64 --decode); \
} \
| cat > updated_chart_values.yaml && \
helm upgrade --dry-run --namespace container-registry -f updated_chart_values.yaml container-registry ./helm_chart/ && \
rm updated_chart_values.yaml
```

Then remove the dry run flag to do the real run.

## Guides

* [Registry Github](https://github.com/docker/docker.github.io)
* [Dockerhub link](https://hub.docker.com/_/registry)
* [Registry Docs](https://docs.docker.com/registry/)
* [Helm Chart github](https://github.com/twuni/docker-registry.helm)
* [Digital Ocean's guide](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-top-of-digitalocean-spaces-and-use-it-with-digitalocean-kubernetes)
* [Another less complete guide](https://dev.to/mkalioby/running-private-docker-registry-for-kubernetes-5693)
* [What is htpasswd](https://en.wikipedia.org/wiki/.htpasswd) - [htpasswd cli](https://httpd.apache.org/docs/2.4/programs/htpasswd.html)
* [Use your own certs](https://docs.docker.com/registry/insecure/)

## Issues


