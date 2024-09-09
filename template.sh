#!/bin/bash
sc_name=$0
set -e
grep env_totel.sh ~/.bashrc    > /dev/null
ls -lh ${ENV_DIR}/env_totel.sh > /dev/null
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh
set +e
# f-marker $sc_name1 $p_all_input_parameters  # move after all the checks

f_use(){
          echo "
 DESC: This is a template script
USAGE:"
  cat << EOF | column -t
EXEC=y VM=el9-090 EL=el9 KS=el9.ks PROTO=static IP=192.168.122.90 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EXEC=y VM=el9-090 EL=el9 KS=no     PROTO=static IP=192.168.122.90 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EXEC=y VM=el8-080 EL=el8 KS=el8.ks PROTO=static IP=192.168.122.80 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EXEC=y VM=el8-080 EL=el8 KS=no     PROTO=static IP=192.168.122.80 DISK_GB=20 RAM_GB=2 CPU=2 $sc_name1
EOF
exit
}

if [ "$1" = "h" ]; then f_use; fi

# Variables with default values
ISO_FILE=${ISO_FILE:=/iso/ol/OracleLinux-R8-U10-x86_64-dvd.iso} 
MYSQL_USERNAME="${MYSQL_USERNAME:=-clustercheckuser}"
p_os_variant="$1";   p_os_variant=${p_os_variant:=el7}

if [ ! -z "${VM}" -a ! -z "${IP}" ]; then
  f-marker $sc_name1 $p_all_input_parameters
else
  f_use
fi
