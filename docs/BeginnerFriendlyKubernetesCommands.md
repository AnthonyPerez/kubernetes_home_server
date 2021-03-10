# Commands

## Debugging

* `kubectl describe <resource_type> -n <namespace> <pod name>` Typically you'll get a message with the error.
* `kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName --all-namespaces`
* `kubectl get events`
* `kubectl top nodes` (with the metrics server enabled.)