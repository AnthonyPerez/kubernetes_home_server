# Deploying Nextcloud

## Prerequisites

This setup assumes you have an ingress controller already setup.

## Deployment Steps

1. Create the required secrets using a command like the following one:

```
kubectl create secret generic -n nextcloud nextcloud-secrets \
    --from-literal=MYSQL_ROOT_PASSWORD=<your-root-password> \
    --from-literal=MYSQL_USER=nextcloud \
    --from-literal=MYSQL_PASSWORD=<your-password>
```

2. Deploy the `nextcloud.yaml` file. `kubectl apply -f apps/nextcloud/deployment/nextcloud.yaml`.

3. Once the nextcloud server is running, log in and set your username and password. The storage & database credentials should already be setup from the deployment's environment variables. If you need to manually set them open the storage & credential settings as use the following parameters:

* 1st line is the DB username you set in the secrets object
* 2nd line is the DB password you set in the secrets object.
* 3rd line is the DB name which can be found in the `nextcloud.yaml` file.
* 4th line is the DB ip address which corresponds to `<service-name>:<service-port>`and can be found in the `nextcloud.yaml` file.

Use `kubectl -n ingress get svc` to find the IP address and (HTTPS) port you need to access (assuming you have followed the instructions for setting up the load balancer).

## Guides

* [NextCloud Docker Github](https://github.com/docker-library/docs/blob/master/nextcloud/README.md)
* [Nice Guide](https://blog.true-kubernetes.com/self-host-nextcloud-using-kubernetes/)
* [Kubernetes Ingress docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)
* [Ingress Explained](https://thenewstack.io/kubernetes-ingress-for-beginners/)

You could also consider deploying [Redis](https://hub.docker.com/_/redis/) to use a memcache (see [here](https://blog.runcloud.io/nextcloud/#69-redis-memory-cache) and [here](https://github.com/acheaito/nextcloud-kubernetes)). I choose not to because free memory is more important to me than nextCloud's performance.
