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
user --groups=wheel --name=osadmin --password=$6$1ox6cXfuU5HlfPwm$Jd2SI.iMXnP6bNUhko3eKvrxy9Dq.jv49iFuZxDcSRyvxGUi9L8sppSOheZKYcOfP8OheZ7NaOhwISP68UJp31 --iscrypted --gecos="osadmin"

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

%post
# Here you can add post-installation tasks
USER=osadmin

echo "# Create /etc/sudoers.d/${USER} with appropriate sudo permissions"
cat <<EOF > /etc/sudoers.d/${USER}
# Grant '${USER}' user full sudo privileges without a password
${USER} ALL=(ALL) NOPASSWD: ALL
EOF

# Set the correct permissions for the sudoers file
chmod 0440 /etc/sudoers.d/${USER}

echo "# Add the injected public key to authorized_keys"
HOME_DIR="/home/$USER"
SSH_DIR="$HOME_DIR/.ssh"
KEY_PUB="Replace with contents of ~/.ssh/id_rsa_kvm.pub"

mkdir -p ${SSH_DIR}
echo "${KEY_PUB}" >> ${SSH_DIR}/authorized_keys 2> ${HOME_DIR}/setup-authorized_keys.log
cp ${KEY_PUB}.pub ${SSH_DIR}/
chmod 700 ${SSH_DIR}
chmod 600 ${SSH_DIR}/authorized_keys
chown $USER:$USER -R ${SSH_DIR}

# Done
echo "Installation complete. Rebooting ....."

# Reboot automatically after installation
%end

reboot

