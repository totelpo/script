#!/bin/bash
# DESC: This is a template script
# totel 20240913 Some info here
# totel 20240816 v2.0 Change input from Positional Parameters to Environment Variable Assignment (Inline Export)

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
  echo "
# USAGE:"
  cat << EOF | column -t
EXEC=y VM=el9-090 IP=192.168.122.90 $sc_name1
EOF
exit 1
}

# Variables with default values
CHECK="${CHECK:="y"}" 

if [ ! -z "${VM}" -a ! -z "${IP}" ]; then # if required variables are not empty
  f-marker VM=${VM} IP=${IP} $sc_name1
# MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker VM=${VM} IP=${IP} $sc_name1  # for minor scripts/checks
  set -e; check-os-support.sh; set +e
else
  # Ensure required variables are defined
  echo "
FAILED: Empty variables found.
VM=${VM} | IP=${IP} "
  f_use
fi

