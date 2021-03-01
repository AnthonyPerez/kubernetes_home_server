# Cluster Setup

### Purchase List

Let N be the number of Pis you want in your cluster. I choose N = 3.

1. N x Raspberry Pi 4 Model B (4GB)
3. N x MicroSD card 32GB
2. 1 x Cat6 ethernet cable
4. 1 x USB Micro SD Card Reader
5. A raspberry pi cluster case.
6. N x Short USB to USB-C cables.
7. A multiport USB charger with at least 10W per port. You will want to check the voltage as well and may need to order multiple if N is large.

### Cluster Architecture

1. Inspired by the guides linked below, we will run a router on one of the master nodes to create a private network for the cluster. This approach will not scale well and will introduce a single point of failure, but will be sufficient for our purposes.

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

5. Allow Ubuntu to boot; DO NOT try to log into Ubuntu as soon as possible. Wait until Cloud-Init runs. If you don't wait you may not be able to logon with the default user and passwd. At the end of the cloud-init,Ubuntu will be rebooted. Wait a couple of minutes for the server to boot. You will see the red power LED flick on and off once when the system reboots. Continue to wait as the system boots a second time.

You will need to connect to each Raspberry Pi in the following setup. Use the ethernet cable to plug the Pi into your computer (unfortunately one at a time).

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

### Setup the Pi Router and Master Node

Copy `setup/cluster_setup` onto the Pi. All the scripts below must be run from the `cluster_setup` directory so that they can reference the config files. Run as the root user by typing `sudo su root` first. 

1. Open `etc/fstab`. Replace the line `LABEL=writable  /        ext4   defaults        0 0` with `LABEL=writable  /        ext4   defaults,noatime        0 0`
2. Run `setup/cluster_setup/pi_setup.sh` and reboot with `sudo reboot`.
3. Set the host name (edit the `etc/hostname` file). I set to `router-master-node`.
4. Run `setup/cluster_setup/router_setup.sh` 
5. Run `setup/cluster_setup/microk8s_setup.sh`
6. Run `setup/cluster_setup/microk8s_master_init.sh`

Make sure you write down (copy paste) the join command that is output when you run  `setup/cluster_setup/microk8s_master_init.sh`
At this point you should disconnect the ehternet cable from your pi router and maker sure that you can SSH into the router.

### Setup the Worker Nodes

1. Copy and run `setup/cluster_setup/pi_setup.sh` 
2. Set the host name (edit the `etc/hostname` file). I followed the naming scheme TODO.
3. Copy and run `setup/cluster_setup/microk8s_setup.sh`
4. Copy and run `setup/cluster_setup/microk8s_worker_init.sh`
5. Run the join command you made a note on in the previous step.

### Join the nodes together

1. TODO


# Sources

1. https://vpn-expert.info/ubuntu-20-04-lts-install-and-setup-on-raspberry-pi-desktop/
2. https://betterprogramming.pub/how-to-set-up-a-raspberry-pi-cluster-ff484a1c6be9
3. https://downey.io/blog/create-raspberry-pi-3-router-dhcp-server/
4. https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview
5. https://raspberrypi.stackexchange.com/questions/111722/rpi-4-running-ubuntu-server-20-04-cant-connect-to-wifi
6. https://raspberrypi.stackexchange.com/questions/169/how-can-i-extend-the-life-of-my-sd-card