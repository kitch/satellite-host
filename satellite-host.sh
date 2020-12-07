#/bin/bash

# Sleep to make sure all network is up, the bridge interface messes wtih this.
sleep 120

#Update hostname
hostnamectl set-hostname nuc-$(dmidecode -s system-serial-number)

# Enable Subscriptions
subscription-manager register --force --username=<RH username> --password=<RH Password>
subscription-manager attach --auto
subscription-manager refresh

# Enable Repos
subscription-manager repos --enable rhel-server-rhscl-7-rpms
subscription-manager repos --enable rhel-7-server-optional-rpms
subscription-manager repos --enable rhel-7-server-rh-common-rpms
subscription-manager repos --enable rhel-7-server-supplementary-rpms
subscription-manager repos --enable rhel-7-server-extras-rpms

# Accept GPG keys
rpm --import /etc/pki/rpm-gpg/*

# Install KVM tools
yum install -y libguestfs-tools-c libvirt-client

# Setup KVM Storage Pool
virsh pool-define-as satellite dir - - - - "/home/satellite/"
virsh pool-build satellite
virsh pool-start satellite
virsh pool-autostart satellite
virsh pool-info satellite

chmod 755 /home/satellite/host-attach.sh
chmod 644 /home/satellite/sat-base.qcow2
chmod 755 /home/satellite/
# Customize VMs
virt-sysprep -a /home/satellite/sat-base.qcow2 --firstboot /home/satellite/host-attach.sh
virt-customize -a /home/satellite/sat-base.qcow2 --root-password password:satellite
for i in {1..3}; do cp -f /home/satellite/sat-base.qcow2 /home/satellite/$(hostname)-sat$i-boot.qcow2; done
for i in {1..3}; do virt-customize --hostname $(hostname)-sat$i -a /home/satellite/$(hostname)-sat$i-boot.qcow2; done

# Launch VMs
for i in {1..1}; do virt-install --name $(hostname)-sat$i --autostart --network bridge=br0 --memory 16384 --vcpus 5 --disk /home/satellite/$(hostname)-sat$i-boot.qcow2 --disk path=/home/satellite/$(hostname)-sat$i-data.qcow2,size=100 --import --os-variant rhel7 --wait 0 --noautoconsole; done
for i in {2..3}; do virt-install --name $(hostname)-sat$i --autostart --network bridge=br0 --memory 8192 --vcpus 4 --disk /home/satellite/$(hostname)-sat$i-boot.qcow2 --disk path=/home/satellite/$(hostname)-sat$i-data.qcow2,size=100 --import --os-variant rhel7 --wait 0 --noautoconsole; done

