# Deploying Nextcloud

## Prerequisites

This setup assumes you have an ingress controller and load balancer already setup.

## Deployment Steps

1. Create the nextcloud namespace with `kubectl apply -f apps/nextcloud/deployment/nextcloud_namespace.yaml`.  Create the required secrets using the following commands. Replace the passwords with your own:

```
kubectl create secret generic -n nextcloud nextcloud-secrets \
    --from-literal=MYSQL_ROOT_PASSWORD=<your-root-password> \
    --from-literal=MYSQL_USER=nextcloud \
    --from-literal=MYSQL_PASSWORD=<your-password>
```

```
openssl req -subj '/CN=192.168.86.201' -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 10000 && \
kubectl create secret generic -n nextcloud nextcloud-tls \
    --from-file=ssl_certificate=cert.pem \
    --from-file=ssl_certificate_key=key.pem && \
rm key.pem cert.pem
```

2. Deploy the `nextcloud.yaml` file. `kubectl apply -f apps/nextcloud/deployment/nextcloud.yaml`.

3. Once the nextcloud server is running, log in and set your username and password. The storage & database credentials should already be setup from the deployment's environment variables. If you need to manually set them open the storage & credential settings as use the following parameters:

* 1st line is the DB username you set in the secrets object
* 2nd line is the DB password you set in the secrets object.
* 3rd line is the DB name which can be found in the `nextcloud.yaml` file.
* 4th line is the DB ip address which corresponds to `<service-name>:<service-port>`and can be found in the `nextcloud.yaml` file.

See `apps/ReadMe.md` for what to type into your browser's address bar.

## Guides

* [NextCloud Docker Github](https://github.com/docker-library/docs/blob/master/nextcloud/README.md)
* [Nice Guide](https://blog.true-kubernetes.com/self-host-nextcloud-using-kubernetes/)
* [Kubernetes Ingress docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)
* [Ingress Explained](https://thenewstack.io/kubernetes-ingress-for-beginners/)
* [NGINX sidecar](https://www.magalix.com/blog/implemeting-a-reverse-proxy-server-in-kubernetes-using-the-sidecar-pattern)

You could also consider deploying [Redis](https://hub.docker.com/_/redis/) to use a memcache (see [here](https://blog.runcloud.io/nextcloud/#69-redis-memory-cache) and [here](https://github.com/acheaito/nextcloud-kubernetes)). I choose not to because free memory is more important to me than nextCloud's performance.

## Issues

* Related to [this issue](https://github.com/nextcloud/helm/issues/10), Nextcloud can take a very long time to start up. You will see it get stuck running `rsync`s which are doing nothing for around 30 minutes to one hour before it switching to running apache.
