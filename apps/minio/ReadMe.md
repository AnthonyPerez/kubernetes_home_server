# Mino

## Install

From the install directory run the following:

- `kubectl apply -f namespace.yaml`
- `kubectl apply -f pv.yaml`

The secret name for the tenant is hardcoded in the `tenant.yaml` file as `minio-tenant-secret`. To create this secret run

```
kubectl create secret generic -n minio minio-tenant-secret \
    --from-literal=accessKey=<your-access-key> \
    --from-literal=secretKey=<your-secret-key>
```
- Run `kubectl get secret -n minio minio-tenant-secret` to check the results. `Data` should be `2` (one for each of the access key and secret key).

- Create a self signed certificate for TLS. Run
```
openssl req -subj '/CN=192.168.86.201' -x509 -newkey rsa:4096 -nodes -keyout private.key -out public.crt -days 10000 && \
kubectl create secret generic -n minio tls-ssl-minio \
    --from-file=private.key \
    --from-file=public.crt && \
rm private.key public.crt
```
The secret name `tls-ssl-minio` is hardcoded into the chart. The path to mount the TLS credentials is also hardcoded and is based on the user minio is running as. This may be a source of errors. 

Now run:
- `helm install --namespace minio -f chart_values.yaml minio-release ./local_chart/`
- `kubectl get all -n minio`
- `kubectl apply -f tenant.yaml` The chart values for the tenant don't allow full customization, so instead we will create our own tenant. Create the tenant after the secret.

## Access minio

In my local copy of the charts I have hard coded in the `192.168.86.201` as the IP address and bounds the ports used by minio to the 9003-9005 range.

To log into the console navigate to the correct IP address and port. You will be prompted for a JWT. You can grab it with `kubectl get secret $(kubectl get serviceaccount console-sa --namespace minio -o jsonpath="{.secrets[0].name}") --namespace minio -o jsonpath="{.data.token}" | base64 --decode`.

- TODO - python example.

## Update Chart Values

- `helm upgrade -f chart_values.yaml minio-release minio/minio-operator`

## Uninstall

- `kubectl delete -f tenant.yaml`
- `helm uninstall --namespace minio minio-release`
- `kubectl delete secret -n minio tls-ssl-minio`
- `kubectl delete secret -n minio minio-tenant-secret`
- `kubectl delete -f pv.yaml`
- `kubectl delete -f namespace.yaml`

## Links

- [Operator Installation](https://github.com/minio/operator/blob/master/README.md)
- [Operator helm chart](https://github.com/minio/operator/tree/master/helm/minio-operator)
- [Operator helm chart values.yaml](https://github.com/minio/operator/blob/master/helm/minio-operator/values.yaml)
- [If you want high performance automatic provisioning of PVCs](https://github.com/minio/direct-csi)
- [Understanding the Tenant CRD](https://github.com/minio/operator/blob/master/helm/minio-operator/templates/tenant.yaml)
- [Understanding the Tenant CRD (2)](https://github.com/minio/operator/blob/master/examples/kustomization/base/tenant.yaml)
- [TLS on Minio](https://github.com/minio/minio/tree/master/docs/tls/kubernetes)