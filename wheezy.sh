#!/bin/bash -xe

apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev
apt-get -y install sudo

usermod -a -G sudo vagrant
sed -e "s/^%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL) NOPASSWD:ALL/g" /etc/sudoers > /etc/sudoers.new
chown root:root /etc/sudoers.new
chmod 0440 /etc/sudoers.new
mv /etc/sudoers.new /etc/sudoers

echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

update-grub

mkdir -pm 700 /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys \
  'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

apt-get -y install nfs-common

sed -e "/^[ \t]*deb[ \t-]/ s/[ \t]contrib//g" \
-e "/^[ \t]*deb[ \t-]/ s/[ \t]non-free//g" \
-e "/^[ \t]*deb[ \t-]/ s/[ \t]main/ main contrib non-free /g" \
"/etc/apt/sources.list" > "/etc/apt/sources.list.new"
mv /etc/apt/sources.list.new /etc/apt/sources.list

# Install the VirtualBox guest additions
apt-get -y install virtualbox-guest-additions

# Start the newly build driver
service vboxadd start

# delete the cache of apt
rm -rf /var/cache/apt/archives/*
rm -rf /var/lib/apt/lists/*
