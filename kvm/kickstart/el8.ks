#version=OL8
# Use text mode install
text

repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream

%packages
@^server-product-environment
kexec-tools
chrony
kexec-tools
bind-utils
net-tools
nfs-utils
wget
nmap
mlocate

%end

# System language
lang en_US.UTF-8

# Network information
network --device enp1s0 --bootproto static --ip 192.168.122.80 --noipv6 --netmask 255.255.255.0 --gateway 192.168.122.1 --nameserver 192.168.122.1,8.8.8.8 --hostname el8-080.localdomain

# Use CDROM installation media
cdrom

# Run the Setup Agent on first boot
firstboot --enable
# Do not configure the X Window System
skipx

ignoredisk --only-use=vda
# System bootloader configuration
bootloader --append="crashkernel=auto" --location=mbr --boot-drive=vda
autopart
# Partition clearing information
clearpart --all --initlabel --drives=vda

# System timezone
timezone Asia/Manila --isUtc

#Root password
rootpw --lock
user --groups=wheel --name=adminpo --password=$6$1ox6cXfuU5HlfPwm$Jd2SI.iMXnP6bNUhko3eKvrxy9Dq.jv49iFuZxDcSRyvxGUi9L8sppSOheZKYcOfP8OheZ7NaOhwISP68UJp31 --iscrypted --gecos="adminpo"

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
