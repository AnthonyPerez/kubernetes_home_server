# Commands

## Debugging

* `kubectl describe <resource_type> -n <namespace> <pod name>` Typically you'll get a message with the error.
* `kubectl edit <resource_type> -n <namespace> <name>` This will let you fix what you did wrong (just make sure your yaml files reflect the final fix).

* `kubectl proxy --address='0.0.0.0' --disable-filter=true` and `http://<Your Server's IP>:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/` to quickly view the dashboard.
* `kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName --all-namespaces`
* `kubectl get events`
* `kubectl top nodes` (with the metrics server enabled.)