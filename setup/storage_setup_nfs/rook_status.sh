echo "kubectl get pods -n rook-nfs-system" && \
kubectl get pods -n rook-nfs-system && \
echo "kubectl get pv" && \
kubectl get pv && \
echo "kubectl get pvc -n rook-nfs" && \
kubectl get pvc -n rook-nfs && \
echo "kubectl get pods -n rook-nfs" && \
kubectl get pods -n rook-nfs && \
echo "kubectl get NFSServer -n rook-nfs" && \
kubectl get NFSServer -n rook-nfs && \
echo "kubectl get sc" && \
kubectl get sc