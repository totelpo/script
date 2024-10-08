# Generated by Anaconda 34.25.4.9
# Generated by pykickstart v3.32
#version=OL9
# Use text mode install
text
repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

# System language
lang en_US.UTF-8

# Network information
network --device enp1s0 --bootproto static --ip 192.168.122.90 --noipv6 --netmask 255.255.255.0 --gateway 192.168.122.1 --nameserver 192.168.122.1,8.8.8.8 --hostname el9-090.localdomain

# Use CDROM installation media
cdrom

%packages
@^minimal-environment
kexec-tools
chrony

%end

# Run the Setup Agent on first boot
firstboot --enable
# Do not configure the X Window System
skipx

# Generated using Blivet version 3.6.0
ignoredisk --only-use=vda
# System bootloader configuration
bootloader --append="crashkernel=1G-64G:448M,64G-:512M" --location=mbr --boot-drive=vda
autopart
# Partition clearing information
clearpart --all --initlabel --drives=vda

# System timezone
timezone Asia/Manila --utc

#Root password
rootpw --lock
user --groups=wheel --name=osadmin --password=$6$1qFTiy2cDxkBy5Kg$Ge8OlF2oK3gg.DOUdvo8vTNexop0jrSt5utq3l/s3qVgn6VDiMp8iM4oxh/gYc5vGsDmtVEdV3xLYEJR1L2Wr/ --iscrypted --gecos="osadmin"

# System services
services --enabled="chronyd"

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

