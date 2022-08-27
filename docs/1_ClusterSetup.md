# Cluster Setup

### Purchase List

Let N be the number of Pis you want in your cluster. I choose N = 3.

1. N x Raspberry Pi 4 Model B (4GB) - Try to go for the 8GB model, in hindsight 8GB would be much better because of the base level of memory usage by k8s and the general demand for memory.
2. N x MicroSD card 32GB
3. 1 x USB Micro SD Card Reader
4. A raspberry pi cluster case.
5. N x Short USB to USB-C cables.
6. A multiport USB charger with at least 10W per port. You will want to check the voltage as well and may need to order multiple if N is large.

### Cluster Architecture

Inspired by the guides linked below, we will run a router on one of the master nodes to create a private network for the cluster. This approach will not scale well and will introduce a single point of failure, but will be sufficient for our purposes.

In general it would be wise to think about the network architecture up front. Two alternatives to consider are (1) using a wired network with a switch and (2) setting up a guest network or alternative SSID to connect the cluster over WiFi.

### Install Ubuntu 20.04 LTS on your SD cards

For each SD card, run through the following two steps (will take between 10 minutes to an hour per SD card.) 

1. Download the offical [Raspberry Pi Imager](https://www.raspberrypi.org/software/)
2. Install and run the imager. Choose the 64-bit Ubuntu Server 20.04.2 LTS.
3. Following [this](https://raspberrypi.stackexchange.com/questions/111722/rpi-4-running-ubuntu-server-20-04-cant-connect-to-wifi) guide: Modify 'network-config' found on the SD Card so that it contains only the items in the example below. Comment out with #, or remove, all other settings including the LAN ones. Enter any missing items. Be certain to maintain only the indentations shown. Use two spaces for each indentation. Remove all tab characters. Replace the SSID with your wireless SSID and the PassPhrase with your wireless passphrase. When done, those two values should be wrapped in quotes. Save the modified file to the SD Card.

```
# This file contains a netplan-compatible configuration which cloud-init
# will apply on first-boot. Please refer to the cloud-init documentation and
# the netplan reference for full details:
#
# https://cloudinit.readthedocs.io/
# https://netplan.io/reference
#

version: 2
renderer: networkd
wifis:
  wlan0:
    dhcp4: true
    dhcp6: true
    optional: true
    access-points:
      "SSID":
         password: "PassPhrase"
```

4. Edit 'user-data' appending the additional lines shown below. Again, use spaces, not tabs and mind the indentation.

```
##Reboot after cloud-init completes
power_state:
  mode: reboot
```

5. Allow Ubuntu to boot; DO NOT try to log into Ubuntu as soon as possible. Wait until Cloud-Init runs. If you don't wait you may not be able to logon with the default user and passwd. At the end of the cloud-init, Ubuntu will be rebooted. Wait a couple of minutes for the server to boot. You will see the red power LED flick on and off once when the system reboots. Continue to wait as the system boots a second time.

You will need to connect to each Raspberry Pi in the following setup. Use the ethernet cable to plug the Pi into your computer (unfortunately one at a time). Alternatively, you can use your home WiFi (easier) if you set it up as in the steps above.

### Assemble your Pis

1. [HeatSinks](https://www.youtube.com/watch?v=E-4GaAz7XNM)
2. [SD Card](https://www.youtube.com/watch?v=wvxCNQ5AYPg)

### SSH into the Pi

1. An optional but recommended step is to set the submask of your ethernet network to be 24 bits in length. This will make subsequent steps much faster.
2. Determine the subnet mask of the ethernet network (reference [this guide](https://rimstar.org/science_electronics_projects/connect_to_raspberry_pi_via_ethernet_directly.htm).)
3. We need to find the raspberry Pi on the network we used. Here are a few options in the order they should be tried.
    1. Login to your router (if you're connecting over WiFi) and see if you can find the device corresponding to the Pi. Note it's IP Address.
    2. Try running `arp -a | findstr dc-a6-32` if you're using a Pi4 or `arp -a | findstr b8-27-eb` otherwise (see [this guide](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#4-boot-ubuntu-server) for more info.)
    3. Use `nmap` to find all devices on that network.  Assuming the subnet mask is `255.255.0.0` run the following command `nmap -sP AAA.BBB.0.0/16` where `AAA` and `BBB` come from your computers address on the network.
4. Run `ping <Pi's IP address>` to detect network connectivity.
5. `ssh ubuntu@<Pi's IP address>`. The password will be `ubuntu` which you should change (you will be forced to when you first SSH into the machine).
6. (If you haven't already connected to WiFi and you want to). Use commandline tools to connect to Wifi. Once you connect to Wifi immediately assign a static IP address to the Pi using your other computer / router / DHCP server. You'll want to write down the IP address of the Pi so you can ssh in again later.

When you SSH into the Pi for the first time the system will require a reboot. Run `sudo reboot`. Wait 3 minutes. SSH back into the Pi.

### Setup the Nodes

Copy `setup/cluster_setup` onto the Pi. All the scripts below must be run from the `cluster_setup` directory so that they can reference the config files. Run as the root user by typing `sudo su root` first. 

1. Open `etc/fstab`. Replace the line `LABEL=writable  /        ext4   defaults        0 0` with `LABEL=writable  /        ext4   defaults,noatime        0 0`
2. Run `setup/cluster_setup/pi_setup.sh`.
2. Set the host name (edit the `/etc/hostname` file). I followed the naming scheme `node2XX` starting from 200 (inclusive).  Only use lowercase alphanumeric characters in your node name.
4. Reserve a static IP address. I choose one with the last byte equal to the number on my worker node (e.g. node `node200` has IP `XXX.XXX.XXX.200`).
5. Run `setup/cluster_setup/microk8s_setup.sh` and reboot with `sudo reboot`.
6. Run `setup/cluster_setup/microk8s_init.sh <username>` (replace <username> with your username which defaults to ubuntu)

### Joining the nodes

Once each worker node has microk8s installed and running, give them 10 minutes. Sometimes microk8s will go down and then restart and this will result in a semi-permanent issue if it happens during cluster connection (fixed by `snap remove microk8s` and `snap install microk8s --classic --channel=1.20/stable` or by reinstalling the operating system with the imager).

For each worker node do the following:

1. On the master node (if you have high-availibility, which is enabled by default, pick an arbitrary but memorable node) run `microk8s add-node`.
2. Copy the command created by the master node and execute it on the worker node you want to join the network.

After joining all nodes, ssh into the master node and run `setup/cluster_setup/microk8s_master_init.sh` to enable add-ons. If you have any configuration preferences for add-ons, you may want to edit the `setup/cluster_setup/microk8s_master_init.sh` file. In particular the load balancer's range of allowed IPs should be configured to match the set of nodes' IP address.

### Debugging

* Join all nodes to your cluster before enabling add-ons (other than high availability). Otherwise nodes joining while high availability is on may fail to join.
* It seems like high availability is a common source of error. Try disabling it. It's relatively new in version 1.20. In future versions, things may be more stable.
* If an node is having trouble connecting to the cluster, or an error occurs when it connects, try running `microk8s remove-node IP-ADDRESS --force` and then removing it's IP address from `/var/snap/microk8s/current/var/kubernetes/backend/cluster.yaml`. This will help to "reset" the node. New nodes should not already be in the `cluster.yaml` file. [Issue](https://github.com/ubuntu/microk8s/issues/1967).
* Consider using `/snap/microk8s/current/bin/dqlite -s file:///var/snap/microk8s/current/var/kubernetes/backend/cluster.yaml -c /var/snap/microk8s/current/var/kubernetes/backend/cluster.crt -k /var/snap/microk8s/current/var/kubernetes/backend/cluster.key -f json k8s ".remove <node-ip-with-port-19001>"` to fix a broken `cluster.yaml`. See [this issue](https://github.com/ubuntu/microk8s/issues/1880#issuecomment-760111637).
* You can also use snap to uninstall and reinstall microk8s.

* Relevant Issues
    * [Error adding 3rd node, fresh install](https://github.com/ubuntu/microk8s/issues/2065)

* If you notice that logs are not being recorded for your nodes, it may be an error in the configuration of log2ram. You may have to check all your nodes, but to check a node do:
  - `cd /var/log`
  - `ls -lh .`  Check if the size of the log folder is near the size limit for log2ram (which is in `setup/cluster_setup/config_files/log2ram.conf`).
  - `tail syslog` do you see a message about the storage device being full? Something like `systemd-journald[XXXX]: Failed to open system journal: No space left on device`.
  - You may need to play with the settings in the config files for `setup/cluster_setup/config_files/log2ram.conf`. Consider setting `size` and `maxsize` in log rotate (see `/etc/logrotate.d` on your system) to lower, potentially much lower than the size limit for `log2ram` to avoid having so many logs that you run out of space in `log2ram`.
  - In my configuration settings (`setup/cluster_setup/config_files/logrotate.d/`)I cap several of the typical log files by setting a maxsize option in the configuration.
  - [An example configuration](https://github.com/kubernetes/kubernetes/blob/master/cluster/gce/gci/configure-helper.sh#L542).
  - To manually rotate logs run `logrotate /etc/logrotate.conf`. Adding the `-d` flag as in `logrotate -d /etc/logrotate.conf` will run logrotate in debug mode which will display what logs would be rotated without rotating the logs.


# Resource Usage

Resource usage assumes you've followed the steps above and includes all services running on the machine, not just microk8s.

* Around 1GB per Pi with no add-ons enabled.
* Around 1.25GB per Pi only high availability enabled.
* Around 1.4GB per Pi with the add-ons enabled by the scripts above.

# Sources

1. https://vpn-expert.info/ubuntu-20-04-lts-install-and-setup-on-raspberry-pi-desktop/
2. https://betterprogramming.pub/how-to-set-up-a-raspberry-pi-cluster-ff484a1c6be9
3. https://downey.io/blog/create-raspberry-pi-3-router-dhcp-server/
4. https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview
5. https://raspberrypi.stackexchange.com/questions/111722/rpi-4-running-ubuntu-server-20-04-cant-connect-to-wifi
6. https://raspberrypi.stackexchange.com/questions/169/how-can-i-extend-the-life-of-my-sd-card