#!/bin/bash
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
EXEC=y VM=el9-090 OS=el9 KS=el9.ks PROTO=static IP=192.168.122.90 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EXEC=y VM=el9-090 OS=el9 KS=no     PROTO=static IP=192.168.122.90 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EXEC=y VM=el8-080 OS=el8 KS=el8.ks PROTO=static IP=192.168.122.80 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EXEC=y VM=el8-080 OS=el8 KS=no     PROTO=static IP=192.168.122.80 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EOF
exit
}

if [ "$1" = "h" ]; then f_use; fi

if [ ! -z "${VM}" -a ! -z "${IP}" ]; then
  f-marker $sc_name1 $p_all_input_parameters
  v_dir=/vm/kvm/${VM}
  mkdir -p ${v_dir}
  f-check-if-dir-is-empty ${v_dir}
  f-check-if-vm-exists    ${VM}
  if [ "$PROTO" = "static" ]; then
    f-check-if-kvm-ip-is-valid ${IP}
    f-check-if-ip-in-used      ${IP}
    f-check-if-similar-vm-exists-based-on-ip ${IP}
  fi
  if   [ "${OS}" = "el8" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ol/OracleLinux-R8-U10-x86_64-dvd.iso}
    OS_VARIANT=${OS_VARIANT:=ol8.10}
    # --osinfo detect=on,require=off \\ # osinfo-query os | cut -c -`tput cols` | grep -i oracle
    NETDEV=${NETDEV:=enp1s0}  # f-el-kickstart-update
  elif [ "${OS}" = "el9" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ol/OracleLinux-R9-U4-x86_64-dvd.iso}
    OS_VARIANT=${OS_VARIANT:=ol9.4}
    NETDEV=${NETDEV:=enp1s0}    # f-el-kickstart-update
  else
    echo "Invalid value OS=${OS}."
    exit 1
  fi
  if [ "${KS}" = "no" ]; then   # use for initial VM creation to get a sample of anaconda-ks.cfg
    v_ks1=
    v_ks2=
  else
    KS_TMP=${TMPDIR}/${KS}
    cp -v ${SCRIPT_DIR}/kvm/kickstart/${KS} $KS_TMP
    v_ks1="--initrd-inject=${KS_TMP}"
    v_ks2="inst.ks=file:/${KS}"
    f-el-kickstart-update 
    unset KS_TMP
  fi
  RAM_GB=${RAM_GB:=2}
  CPU=${CPU:=2}
  cat << EOF > $sc_tmp-${OS}.sh
set -e
virt-install \\
--network bridge:virbr0,model=virtio \\
--name ${VM} \\
--ram=$((1024*RAM_GB)) \\
--vcpus=${CPU} \\
--disk path=${v_dir}/root.img,size=${DISK_GB},bus=virtio \\
--location=${ISO_FILE} \\
--os-variant ${OS_VARIANT} \\
--graphics none \\
${v_ks1} \\
--extra-args="${v_ks2} ip=192.168.122.2 netmask=255.255.255.0 gateway=192.168.122.1  console=ttyS0,115200n8" 

set +e
EOF
  echo EXEC=${EXEC}
  f-exec-temp-script $sc_tmp-${OS}.sh
else
  f_use
fi
