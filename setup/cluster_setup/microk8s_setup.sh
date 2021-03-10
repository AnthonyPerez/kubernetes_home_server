# Add cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 to /boot/firmware/cmdline.txt
sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1/' /boot/firmware/cmdline.txt

# Create /etc/sysctl.d/k8s.conf
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF