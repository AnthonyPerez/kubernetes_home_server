# Disable Swap - Will increase SD card life.
# This seems to come disabled when folloing the image instructions, so this command does nothing.
swapoff --all

# Store /var/log in RAM - Will increase SD card life. - Do this last because it requires a reboot
echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list && \
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add - && \
apt update && \
apt-get install log2ram && \
cp ./config_files/logrotate.conf /etc/logrotate.conf && \
cp ./config_files/logrotate.d/* /etc/logrotate.d/ && \
cp ./config_files/log2ram.conf /etc/log2ram.conf
