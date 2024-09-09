#!/bin/bash
# totel 20240909 Create script and add to github
sc_name=$0

source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

v_log=$sc_tmp.log

f_use() {
        echo "
 DESC : This script will copy scripts needed by the VM
USAGE : 
IP=192.168.122.90 $sc_name1
" | sed "s|$HOME|~|g"

exit
}

if [ ! -z "${IP}" ]; then
  f-marker $sc_name1 $p_all_input_parameters
else
  f_use
fi

set -e 
f_main(){
  v_dir=$1
  v_file_list=vm-remote-${v_dir}.list
cd ${SCRIPT_DIR}/${v_dir}/
if [ ! -f ${v_file_list} ]; then
  ls -lh ${v_file_list}
  exit 1
fi
v_list="`echo $(grep -v '^#' ${v_file_list} )`"
sh -xc "rsync -a ${v_list} ${IP}:script/${v_dir}/"
}

sh -xc "rsync -a ${SCRIPT_DIR}/remote/*.sh ${IP}:script/bin/"
f_main function
f_main env

