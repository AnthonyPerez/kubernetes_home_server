# Commands

## Debugging

* `kubectl describe <resource_type> -n <namespace> <pod name>` Typically you'll get a message with the error.
* `kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName --all-namespaces`
* `kubectl get events`
* `kubectl top nodes` (with the metrics server enabled.)
* If you need to reset a container (e.g. to reload a mounted configmap) you can run `kubectl exec POD_NAME -c CONTAINER_NAME -- /sbin/killall5` or `kubectl exec POD_NAME -c CONTAINER_NAME -- reboot`
* If you want to access the dashboard before setting it up correctly, you can run `kubectl get secrets -n kube-system` and then `kubectl get secrets -n kube-system <kubernetes-dashboard-token> --template={{.data.token}} | base64 --decode` to get the token. Replace `<kubernetes-dashboard-token>` with your token secret name.