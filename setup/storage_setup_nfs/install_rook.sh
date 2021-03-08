git clone --branch v1.5.4 https://github.com/rook/rook && \
kubectl apply -f rook/cluster/examples/kubernetes/nfs/common.yaml && \
kubectl apply -f rook/cluster/examples/kubernetes/nfs/operator.yaml && \
# kubectl apply -f setup/storage_setup_nfs/psp.yaml && \
kubectl apply -f rook/cluster/examples/kubernetes/nfs/rbac.yaml && \
kubectl apply -f setup/storage_setup_nfs/nfs_server.yaml && \
kubectl apply -f setup/storage_setup_nfs/sc.yaml