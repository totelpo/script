#!/bin/bash
# totel 20240913 Some info here

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: This is a template script
USAGE:"
  cat << EOF | column -t
EXEC=y VM=el9-090 IP=192.168.122.90 $sc_name1
EOF
exit 1
}

# Variables with default values
VM="${VM:=el9-090}" 
IP="${IP:=192.168.122.90}"
EXEC="${EXEC:=n}" 

if [ ! -z "${VM}" -a ! -z "${IP}" ]; then # if required variables are not empty
  MARKER_WIDTH=105 f-marker $sc_name1 $p_all_input_parameters    # MARKER_WIDTH=105 for main script; MARKER_WIDTH=100(default) for minor script
else
  f_use
fi

echo "Generate some script here" > $sc_tmp.sh

if [ "${EXEC}" = "y" ]; then
  bash -x $sc_tmp.sh
else
  echo "We need to manually execute :\nbash -x $sc_tmp.sh"
fi
