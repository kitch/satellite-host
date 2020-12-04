lang en_US
keyboard us
timezone America/New_York --isUtc
rootpw $6$OAQcWKFZUYB3BcaO$oCJk0Obf3v/P4FJeJYH6lyA54mCW.SpPuqzuisn0C5hmtZSJmxh3H2mykMl7h5ZbvEAYjs/hQQQAnTymTs0Pk/ --iscrypted
#platform x86, AMD64, or Intel EM64T
reboot
text
cdrom
bootloader --location=mbr --append="rhgb quiet crashkernel=auto"
zerombr
clearpart --all --initlabel
autopart

# License agreement
eula --agreed

# Network information
network  --bootproto=dhcp --device=br0 --ipv6=auto --activate --bridgeslaves=eno1 --bridgeopts=priority=32768,stp=yes --onboot=on
network  --bootproto=dhcp --device=enp111s0 --onboot=off --ipv6=auto
network  --bootproto=dhcp --hostname=satellite

auth --passalgo=sha512 --useshadow
selinux --enforcing
firewall --enabled --ssh --port=5091
firstboot --disable

user --groups=wheel --name=satellite --password=$6$OAQcWKFZUYB3BcaO$oCJk0Obf3v/P4FJeJYH6lyA54mCW.SpPuqzuisn0C5hmtZSJmxh3H2mykMl7h5ZbvEAYjs/hQQQAnTymTs0Pk/ --iscrypted --gecos="satellite"

%packages
@^graphical-server-environment
@network-server
@debugging
@hardware-monitoring
@network-tools
@console-internet
@virtualization-tools
@virtualization-platform
@virtualization-client
@virtualization-hypervisor
%end


%post --log=/root/ks-post2.log
touch /tmp/runonce
cat << EOF > /etc/systemd/system/runonce.service
[Unit]
Description=Run once
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/root/runonce.sh

[Install]
WantedBy=multi-user.target
EOF

chmod 664 /etc/systemd/system/runonce.service
systemctl enable runonce
%end

%post --nochroot --log=/root/ks-post.log
mkdir -p /mnt/sysimage/home/satellite/
cp /run/install/repo/satellite/sat-base.qcow2 /mnt/sysimage/home/satellite/sat-base.qcow2
cp /run/install/repo/satellite/runonce.sh /mnt/sysimage/root/runonce.sh
cp /run/install/repo/satellite/satellite-hosts.sh /mnt/sysimage/root/satellite-hosts.sh
cp /run/install/repo/satellite/host-attach.sh /mnt/sysimage/home/satellite/host-attach.sh
%end
