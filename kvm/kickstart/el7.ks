#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use text mode install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts=''
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=eth0 --gateway=192.168.122.1 --ip=192.168.122.2 --netmask=255.255.255.0 --ipv6=auto --activate
network  --hostname=localhost.localdomain

repo --name="Server-HighAvailability" --baseurl=file:///run/install/repo/addons/HighAvailability
repo --name="Server-ResilientStorage" --baseurl=file:///run/install/repo/addons/ResilientStorage
#Root password
rootpw --lock
# System services
services --enabled="chronyd"
# Do not configure the X Window System
skipx
# System timezone
timezone Asia/Manila --isUtc
user --groups=wheel --name=osadmin --password=$6$j05h09eoS6AJPhiT$g4PokeOPtNHfG54DK79.cXM.SYb5tFBg4BcjEpiHJ2eFUMEGYPk60NvxHZQke6WZaSDjvAE2MNFcmHUecbeSo1 --iscrypted --gecos="osadmin"
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel --drives=vda

%packages
@core
chrony
kexec-tools

%end

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

