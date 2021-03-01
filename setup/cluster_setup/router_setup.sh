# Main references:
# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md
# https://downey.io/blog/create-raspberry-pi-3-router-dhcp-server/

# Setup 2nd wireless network. - Network inferences live in /etc/netplan/50-cloud-init.yaml
# Reference: https://netplan.io/examples/
# Maybe relevant: https://medium.com/@exesse/how-to-make-a-simple-router-gateway-from-ubuntu-server-18-04-lts-fd40b7bfec9

##################################################

# apt-get install -y hostapd && \
# systemctl unmask hostapd && \
# systemctl enable hostapd && \
# apt-get install-y  dnsmasq && \
# DEBIAN_FRONTEND=noninteractive apt-get install -y netfilter-persistent iptables-persistent && \

