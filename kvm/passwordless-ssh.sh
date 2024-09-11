#!/bin/bash
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: This is a template script
USAGE:
OS=el9 IP=192.168.122.90 $sc_name1
"
}

if [ ! -z "${OS}" -o ! -z "${IP}" ]; then
  f-marker $sc_name1 $p_all_input_parameters
  set -e
  echo; sh -xc "ssh-keygen -f ${HOME}/.ssh/known_hosts -R ${IP}"
  echo
  if [ "${OS}" = "el5" ]; then
          sh -xc "ssh-copy-id -i ${HOME}/.ssh/id_rsa_kvm -o HostKeyAlgorithms=+ssh-rsa ${IP}"
  else
          sh -xc "ssh-copy-id -i ${HOME}/.ssh/id_rsa_kvm ${IP}"
  fi
  echo -e "\n# Test passwordless SSH :"
  sh -xc "ssh -i ${HOME}/.ssh/id_rsa_kvm ${IP} id"
else
  f_use
fi
