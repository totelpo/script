#!/bin/bash
# Called by : vm-template.sh

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
  echo -e "USAGE : \n"
  cat << EOF > /tmp/env.sh
export VM=el8-085
export KS=el8.ks   
#xport KS=no      # use for initial VM creation to get a sample of anaconda-ks.cfg and value for network device name(NETDEV)
export OS=el8
export PROTO=static
export ISO_FILE=/iso/ol/OracleLinux-R9-U4-x86_64-dvd.iso
export IP=192.168.122.85
export DISK_GB=80
export RAM_GB=2
export CPU=2
EOF
sh -xc 'cat /tmp/env.sh'
echo 
  cat << EOF 
. /tmp/env.sh
EXEC=y $sc_name1

# or
EXEC=y VM=el9-090 OS=el9 KS=no     PROTO=static IP=192.168.122.90 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EXEC=y VM=el9-090 OS=el9 KS=el9.ks PROTO=static IP=192.168.122.90 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EXEC=y VM=el8-080 OS=el8 KS=el8.ks PROTO=static IP=192.168.122.80 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EXEC=y VM=el7-070 OS=el7 KS=el7.ks PROTO=static IP=192.168.122.70 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EOF
exit
}

if [ "$1" = "h" ]; then f_use; fi
CHECK="${CHECK:=y}"

if [ ! -z "${VM}" -a ! -z "${IP}" ]; then
  MARKER_WIDTH=${COLUMNS} f-marker $sc_name1 OS=${OS} VM=${VM} IP=${IP}
  v_dir=${KVM_DIR}/${VM}
  if [ "${CHECK}" = "y" ]; then
    set -e # needed to exit if the check script fails
    check-if-vm-exists.sh
    DIR_NAME=${v_dir} check-if-dir-is-empty-or-not-exists.sh
    if [ "$PROTO" = "static" ]; then
      check-if-kvm-ip-is-valid.sh
      check-if-ip-in-used.sh
      check-if-similar-vm-exists-based-on-ip.sh
    fi
    set +e
  fi
  mkdir -p ${v_dir}
  if   [ "${OS}" = "el7" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ol/OracleLinux-R7-U9-Server-x86_64-dvd.iso}
    OS_VARIANT=${OS_VARIANT:=ol7.9} # --osinfo detect=on,require=off \\ # osinfo-query os | cut -c -`tput cols` | grep -i oracle
    NETDEV=${NETDEV:=eth0}  # f-el-kickstart-update
   elif [ "${OS}" = "el8" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ol/OracleLinux-R8-U10-x86_64-dvd.iso}
    OS_VARIANT=${OS_VARIANT:=ol8.10} # --osinfo detect=on,require=off \\ # osinfo-query os | cut -c -`tput cols` | grep -i oracle
    NETDEV=${NETDEV:=enp1s0}  # f-el-kickstart-update
  elif [ "${OS}" = "el9" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ol/OracleLinux-R9-U4-x86_64-dvd.iso}
    OS_VARIANT=${OS_VARIANT:=ol9.4} # --osinfo detect=on,require=off \\ # osinfo-query os | cut -c -`tput cols` | grep -i oracle
    NETDEV=${NETDEV:=enp1s0}    # f-el-kickstart-update
  else
    echo "Unsupported value OS=${OS}."
    exit 1
  fi
  if [ "${KS}" = "no" ]; then   # use for initial VM creation to get a sample of anaconda-ks.cfg and NETDEV
    v_ks1=
    v_ks2=
  else
    KS_TMP=${TMPDIR}/${KS}
    cp ${SCRIPT_DIR}/kvm/kickstart/${KS} $KS_TMP
    v_ks1="--initrd-inject=${KS_TMP}"
    v_ks2="inst.ks=file:/${KS}"
    v_console="--noautoconsole"
    f-el-kickstart-update 
  fi
  RAM_GB=${RAM_GB:=2}
  CPU=${CPU:=2}

  (
  cat << EOF
virt-install \\
--network bridge:virbr0,model=virtio \\
--name ${VM} \\
--ram=$((1024*RAM_GB)) \\
--vcpus=${CPU} \\
--disk path=${v_dir}/root.img,size=${DISK_GB},bus=virtio \\
--location=${ISO_FILE} \\
--os-variant ${OS_VARIANT} \\
--graphics none \\
EOF
  if [ ! "${KS}" = "no" ]; then
    cat << EOF
${v_console} \\
${v_ks1} \\
EOF
  fi
  cat << EOF
--extra-args="${v_ks2} ip=192.168.122.2 netmask=255.255.255.0 gateway=192.168.122.1  console=ttyS0,115200n8" 
EOF
  ) > $sc_tmp-${OS}.sh.virt-install

  (
  cat << EOF
(
set -e

f-exec-temp-script $sc_tmp-${OS}.sh.virt-install

EOF

  if [ ! "${KS}" = "no" ]; then
    cat << EOF
VM=${VM} WAIT_MINUTE=9 check-auto-shutdown-then-start.sh
IP=${IP}
EOF
  else
    cat << EOF
VM=${VM} WAIT_MINUTE=6 f-ip-wait-kvm-to-acquire; IP=\${r_ip}
EOF
  fi

  cat << EOF
IP=\${IP}  PORT=22  WAIT_MINUTE=9  check-port-wait-to-open.sh

# OS=${OS} IP=\${IP} passwordless-ssh.sh
f-marker "Clear old entries for \${IP} on ~/.ssh/known_hosts"
echo; sh -xc "ssh-keygen -f ${HOME}/.ssh/known_hosts -R \${IP}"

f-marker "Check anaconda.log for OS install start and finish"
ssh -o 'StrictHostKeyChecking=no' \${IP} "sudo less /var/log/anaconda/anaconda.log | sed -n '1p; \\\$p'"

vm-arp-clear-unreachable-ip.sh

set +e
echo "
Setup of ${OS} ${VM} is now complete.
"
)
EOF
  ) > $sc_tmp-${OS}.sh

  if [ "${EXEC}" = "y" ]; then
    f-exec-temp-script $sc_tmp-${OS}.sh
  else
    echo "
Review :
${KS_TMP} 
$sc_tmp-${OS}.sh.virt-install
$sc_tmp-${OS}.sh

We need to manually execute :
EXEC=y f-exec-temp-script $sc_tmp-${OS}.sh
"
  fi
else
  f_use
fi
