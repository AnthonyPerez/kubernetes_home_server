kubectl delete -f setup/storage_setup_nfs/sc.yaml && \
kubectl delete -f setup/storage_setup_nfs/nfs_server.yaml && \
kubectl delete -f rook/cluster/examples/kubernetes/nfs/rbac.yaml && \
# kubectl delete -f setup/storage_setup_nfs/psp.yaml && \
kubectl delete -f rook/cluster/examples/kubernetes/nfs/operator.yaml && \
kubectl delete -f rook/cluster/examples/kubernetes/nfs/common.yaml