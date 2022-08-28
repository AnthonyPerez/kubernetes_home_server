# Mino

## Install

- Login to the node where the minio persistent volume will be created and run `mkdir /mnt/hdd1/minio`.
- From the install directory run the following:
    - `kubectl apply -f namespace.yaml`
    - `kubectl apply -f pv_pvc.yaml`

- The minio secret name is hardcoded in the chart and/or chart values as `minio-access-secret`. To create this secret run

```
kubectl create secret generic -n minio minio-access-secret \
    --from-literal=accesskey=$(uuidgen) \
    --from-literal=secretkey=$(uuidgen)
```
- Run `kubectl get secret -n minio minio-access-secret` to check the results. `Data` should be `2` (one for each of the access key and secret key).
- Run `kubectl get secret -n minio minio-access-secret -o jsonpath="{.data.accesskey}" | base64 --decode` to see the access key.

- Create a self signed certificate for TLS. Run
```
openssl req -subj '/CN=192.168.86.201' -x509 -newkey rsa:4096 -nodes -keyout private.key -out public.crt -days 10000 && \
kubectl create secret generic -n minio tls-ssl-minio \
    --from-file=private.key \
    --from-file=public.crt && \
rm private.key public.crt
```
The secret name `tls-ssl-minio` is hardcoded into the chart and/or chart values. 

- Now run:
    - `helm install --namespace minio -f chart_values.yaml minio-release ./local_chart/`
    - `kubectl get all -n minio`

## Access minio

- Minio should be accessible from `192.168.86.201:9003` over HTTPS.
- Get the access key via `kubectl get secret -n minio minio-access-secret -o jsonpath="{.data.accesskey}" | base64 --decode`.
- Get the secret key via `kubectl get secret -n minio minio-access-secret -o jsonpath="{.data.secretkey}" | base64 --decode`.

- The test includes a python example.

## Test

From inside the tests folder run

- `kubectl apply -f test_namespace.yaml`
-
```
kubectl create secret generic -n test-minio test-minio-secret \
    --from-literal=accesskey=$(kubectl get secret -n minio minio-access-secret -o jsonpath="{.data.accesskey}" | base64 --decode) \
    --from-literal=secretkey=$(kubectl get secret -n minio minio-access-secret -o jsonpath="{.data.secretkey}" | base64 --decode)
```
- `kubectl apply -f test_minio.yaml`

- `kubectl get all -n test-minio`
- `kubectl describe pod -n test-minio` If the pod doesn't fail then things are working.

- `kubectl delete -f test_minio.yaml`
- `kubectl delete secret -n test-minio test-minio-secret`
- `kubectl delete -f test_namespace.yaml` Deleting the namespace will clean everything used for testing

## Update Chart Values

- First dry run with `helm upgrade --namespace minio --dry-run -f chart_values.yaml minio-release ./local_chart/` 
- `helm upgrade --namespace minio -f chart_values.yaml minio-release ./local_chart/`

## Uninstall

- `helm uninstall --namespace minio minio-release`
- `kubectl delete secret -n minio tls-ssl-minio`
- `kubectl delete secret -n minio minio-access-secret`
- `kubectl delete -f pv.yaml`
- `kubectl delete -f namespace.yaml`  Deleting the namespace will delete all the above resources.

## Notes

A couple caveats on what is in the charts.
- The memory limit is very low. Minio may fail for large objects or many concurrent requests.
- I set MINIO_API_REQUESTS_MAX to 4 to reduce memory usage due to processing multiple requests.
- I have disabled the cache to save on memory.
- The browser is still enabled.
- I have not configured the domain names.

The chart itself is not modified, but a local copy of the version used is provided.

## Links

- [Legancy Minio Chart](https://github.com/minio/charts) - Used here because the operator chart does not support a standalone minio deployment (and is too heavy for the standalone use case).
- [TLS on Minio](https://github.com/minio/minio/tree/master/docs/tls/kubernetes)
- [Simple Standalone example](https://github.com/kubernetes/examples/tree/master/staging/storage/minio)
- [Alternative Minio Chart - does not use the operator](https://github.com/minio/minio/tree/master/helm/minio)

### Operator

Note that [the operator does not support standalone mode](https://github.com/minio/operator/issues/677).

- [Operator Installation](https://github.com/minio/operator/blob/master/README.md)
- [Operator helm chart](https://github.com/minio/operator/tree/master/helm/minio-operator)
- [Operator helm chart values.yaml](https://github.com/minio/operator/blob/master/helm/minio-operator/values.yaml)
- [If you want high performance automatic provisioning of PVCs](https://github.com/minio/direct-csi)
- [Understanding the Tenant CRD](https://github.com/minio/operator/blob/master/helm/minio-operator/templates/tenant.yaml)
- [Understanding the Tenant CRD (2)](https://github.com/minio/operator/blob/master/examples/kustomization/base/tenant.yaml)