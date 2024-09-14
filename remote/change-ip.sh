#!/bin/bash
# totel 20240914 Unmount NFS volumes then Change IP

sc_name=$0

source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
  echo "
USAGE :
OS=el9  NEW_IP=192.168.122.91 $sc_name1 
"
  exit
}

if [ ! -z "${OS}" -a ! -z "${NEW_IP}" ]; then # if required variables are not empty
  f-marker $sc_name1 ${OS} NEW_IP=${NEW_IP}
  set -e; check-os-support.sh; set +e

  v_dev="`ip a | grep -v '^ ' | grep -v ' lo:' | head -1 | awk '{ print $2 }' | sed 's/://'`"
  v_old_ip="`ip -4 addr show  dev ${v_dev} | grep inet | awk '{ print $2 }' | cut -d'/' -f1`"

  f_check_ip(){
    f-marker ${FUNCNAME[0]}
    echo "${NEW_IP}" | grep 192.168.122
    if [ $? -gt 0 ]; then
      echo "Invalid IP ${NEW_IP} . IP must be 192.168.122.X"
      exit 1
    fi
    if [ "$v_old_ip" = "${NEW_IP}" -o "${NEW_IP}" = "0" ]; then
      echo -e "\nNo IP changed. Old and new IP are the same.\n"
      exit
    fi
    ping -c 1 ${NEW_IP} > /dev/null
    if [ $? -eq 0 ]; then 
      echo "\nIP conflict for ${NEW_IP}\n" 
      exit 1
    fi
  }
  f_check_ip

  f_change_ip_network_scripts(){
    f-marker ${FUNCNAME[0]}
    v_cfg=/etc/sysconfig/network-scripts/ifcfg-${v_dev}
    if [ ! -f $v_cfg ]; then
      ls -lh $v_cfg
      exit
    fi
    grep "^BOOTPROTO=" $v_cfg || echo "BOOTPROTO=" >> $v_cfg
    grep "^IPADDR="    $v_cfg || echo "IPADDR="    >> $v_cfg
    grep "^NETMASK="   $v_cfg || echo "NETMASK="   >> $v_cfg
    sed -i "
 s/^BOOTPROTO=.*/\BOOTPROTO=static/
;s/^IPADDR=.*/IPADDR=${NEW_IP}/
;s/^NETMASK=.*/NETMASK=255.255.255.0/
" $v_cfg
    set +e
    f-umount-all-nfs
    set -e
          ifdown ${v_dev}
          ifup   ${v_dev}
    sleep 5
    mount -a
  }
  
  f_change_ip_networkd(){
    f-marker ${FUNCNAME[0]}
    cd /etc/netplan/
    cp -nv 00-installer-config.yaml 00-installer-config.yaml.bkp
    set +e
    grep 192.168.122 00-installer-config.yaml > /dev/null
    v_grep_exit_status=$?
    set -e
    echo $v_grep_exit_status
    if [ $v_grep_exit_status -eq 0 ]; then
      sed -i "s|- 192.168.122.*/24|- ${NEW_IP}/24|" 00-installer-config.yaml
    else
      # https://linuxize.com/post/how-to-configure-static-ip-address-on-ubuntu-20-04/
      cat << EOF > 00-installer-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ${v_dev}:
      dhcp4: no
      addresses:
        - ${NEW_IP}/24
      gateway4: 192.168.122.1
      nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
EOF
    fi
    netplan apply
    sleep 1
    ip a | grep 'inet '
  }

  f_change_ip_networking(){
    f-marker ${FUNCNAME[0]}
    v_conf=/etc/network/interfaces
    cp -nv $v_conf $v_conf.bkp
    set +e
    grep "^iface ${v_dev} inet dhcp" $v_conf 
    if [ $? -eq 0 ]; then
      sed -i "/^iface ${v_dev} inet dhcp/d" $v_conf
      cat << EOF >> $v_conf
iface ${v_dev} inet static
        address ${NEW_IP}
        netmask 255.255.255.0
        gateway 192.168.122.1
dns-nameservers 192.168.122.1 8.8.8.8
EOF
    else
      sed -i "s/ address .*/ address ${NEW_IP}/" $v_conf
    fi
    echo
    set -e
    sh -x << EOF
/etc/init.d/networking restart
sleep 1
cat /etc/resolv.conf
EOF
    echo -e "\n# $v_conf"
    grep . $v_conf | grep -v '^#'
    echo "
###  IMPORTANT  
# On guest      : Requires VM sever restart so the old IP will be gone
# On KVM server : Manually clear ARP cache IPs to prevent Old IPs from appearing in vm-list.sh script
sudo ip -s -s neigh flush all
arp -en
"
  }

  f_ip_ubuntu_nmcli(){
    f-marker ${FUNCNAME[0]}
    set +e
    cd /etc/netplan/
    grep 'renderer: NetworkManager' 00-installer-config.yaml 
    # netplan apply # after a change to 00-installer-config.yaml
  
    if [ $? -eq 0 ]; then
      f-change-ip-nmcli   
    else
      echo "# renderer must be NetworkManager"
      grep 'renderer: ' 00-installer-config.yaml
    fi
  }

  echo -e "\n# Logging to : ${sc_tmp}.log\n"
  set -e
  (
  if   [ "${OS}" = "el7" -o "${OS}" = "el8" -o "${OS}" = "el9" ]; then
    f-change-ip-nmcli
  elif [ "${OS}" = "el5" -o "${OS}" = "el6" ]; then
    f_change_ip_network_scripts
  elif [ "${OS}" = "u20"   -o "${OS}" = "u22" ]; then
    f_change_ip_networkd
  elif [ "${OS}" = "u16" ]; then
    f_change_ip_networking
  fi
  f-marker "Gather Info 2"
  echo "
ip -4 addr show  dev ${v_dev}
lshw -class network -short
" | sh -x
  echo
  f-check-ping
  ) 2>&1 &> ${sc_tmp}.log
else
  f_use
fi
  
