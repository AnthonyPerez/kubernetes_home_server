# Apps

## Storage

Node 201 - 298Gi

* NFS 100Gi - /mnt/hdd1/nfs/
* Minio 198Gi - /mnt/hdd1/minio/

Node 202 - 298Gi

* NextCloud 50Gi - /mnt/hdd1/nextcloud/
* Container Registry 198Gi - /mnt/hdd1/container_registry/

### Minio Buckets

- "default" - no particular use.
- "argo" - used by argo.

## Networking

Apps are deployed using services of type `LoadBalanced` to the IP address `192.168.86.201` (the ingress already uses `192.168.86.200` and is a nice to have). For the sake of simplicity, all apps will use sequential ports starting from 9000. Here are the currently requisitioned ports.

Access each service by using `https://192.168.86.201:<HTTPS Port>` e.g. `https://192.168.86.201:9000` to access the dashboard.

- Kubernetes Dashboard
    - Port: 9000, TCP/HTTPS
- Next Cloud
    - Port: 9001, TCP/HTTP
    - Port: 9002, TCP/HTTPS
- Minio
    - Port: 9003, TCP/HTTPS
- Argo
    - Port: 9004, TCP/HTTPS
- Container Registry
    - Port: 9005, TCP/HTTPS

### Ingress

It would be preferable to use the ingress mechanism rather than services, but this requires either the managing the host names of the ingress resources or managing DNS and certifications. To avoid that, I've decided to use the scheme above.

## A note on power draw

The Pi 4B runs somewhere between 3W at idle and 6W at max CPU based on benchmarks you'll fine googling around. That's 2.2-4.4 kWh/month. At $0.22/kWh (as an example), you'll spend $0.97/month for each Pi.

# A note on namespaces

Many of the apps deployed here are deployed in their own namespace. However, this is not [standard practice](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/).
