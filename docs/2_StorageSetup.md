# Storage Setup

We will install NFS + Rook to orchestrate storage on our cluster. The instructions below are pulled from [the Rook quickstart guide](https://rook.io/docs/rook/v1.5/nfs.html).

Note that this guide won't cover pod security policies. If `kubectl get podsecuritypolicies.policy -A` returns something, consult the official rook guides.

Also, there are [many storage options out there](https://computingforgeeks.com/storage-solutions-for-kubernetes-and-docker/) for you to choose from.

# Install Rook NFS

## Per Node Setup

Run the following steps on each node with storage.

1. Attach any external disks you would like to use for storage.
2. Make sure you can see your new storage devices with `lsblk -f`.
    * If your device already has a file system use `fdisk` to delete any partitions on the disk and free all the space.
3. Use `fdisk /dev/sda`, replacing `sda` with your device name to remove all partitions and create a new one. First type p to see the partitions. If there are none, type n, p, 1 and choose the defaults, then hit w to save (or q if you made a mistake and want to quit).
    * Record the space available on each device using `fdisk`. The example configs use `298Gi`.
4. Use `mkfs.ext4` to create a filesystem on the new partition.
5. Open `/etc/fstab` on each node and add all storage devices. You can find their UUIDs with `lsblk -f`. Use the following example:
    * `UUID=ce20c7d1-ccbd-4d54-8d3b-55574bd150ea       /mnt/hdd1/      ext4    defaults,noatime        0       0`
6. Run `setup/storage_setup_nfs/prerequisites.sh`. Note: Run this script on all nodes, even those without the backing NFS storage device.
7. Run `mkdir /mnt/hdd1/nfs` to make a directory named `nfs` on the mounted disk. This will be reserved for the NFS.

## Rook NFS Setup (Master Node)

On the master node (with microk8s in high availability every node is a master node).

1. Open the `setup/storage_setup_nfs/nfs_server.yaml` file and create an NFS Server object following the example for each storage device attached. You can see all settings [here](https://rook.io/docs/rook/v1.5/nfs-crd.html). Things to check:
    * The mount path
    * The volume size in the volume and the claim
    * The number of devices
    * The node names
    * Matching names for the PV and PVC across each set of PV+PVC+NFSServer

Note that we use two NFSServers in the example (even though multiple claims can be attached to the same server) because the server pod must run on the same node as the disk it is accessing when we use local persistent volumes. Our persistent volumes are on different nodes in the example. But one NFSServer should be used for each node (with attached storage), and create a share for all of the persistent volumes on the node.
 
2. Open `setup/storage_setup_nfs/sc.yaml` and create one storageClass for each share.
    * Note that the provisioner API path also changes with the `NFSServer` name. `nfs.rook.io/{NFSServer Name}-provisioner`
3. Run `setup/storage_setup_nfs/install_rook.sh`. Things to check:
    * `kubectl get nfsservers.nfs.rook.io -n rook-nfs`
    * `kubectl get pod -n rook-nfs`
    * `kubectl describe sc node201-store`

If you would like to use the rook NFS storage class as the default storage class run the following (test things first).

1. Unmark the microk8s storageclass as the default `kubectl patch storageclass microk8s-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'`
    * Run `kubectl get storageclass` to see storageclasses.
2. Mark one of the NFS share storage classes as the default `kubectl patch storageclass node201-store -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`

## Test things

* Use `kubectl apply -f setup/storage_setup_nfs/test_nfs.yaml` to setup a small test deployment that has 5 busy boxes reading and writing to a single NFS PVC.
* Use `kubectl delete -f setup/storage_setup_nfs/test_nfs.yaml` to tear it down.

## Debugging

* Make sure RBAC is enabled on the cluster. Otherwise PVC will stay stuck in a pending state.
* Make sure you are running microk8s with kubectl and kube-apiserver in priviledged mode.

## Sources

1. https://marcbrandner.com/blog/your-very-own-kubernetes-readwritemany-storage/
2. https://rook.io/docs/rook/v1.5/nfs.html
3. https://rook.io/docs/rook/v1.5/nfs-crd.html
4. [Disk formatting](https://recoverit.wondershare.com/harddrive-tips/format-and-wipe-linux-disk.html)
