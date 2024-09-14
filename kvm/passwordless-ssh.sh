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
  f-marker $sc_name1 IP=${IP}

# Check if SSH connection works without a password
ssh -o BatchMode=yes -o ConnectTimeout=5 ${IP} 'exit'

# Capture the exit status
if [ $? -eq 0 ]; then
  echo "Passwordless SSH is already working!"
else
  echo "Passwordless SSH is NOT working. We will proceed for its setup."

    set -e
    echo; sh -xc "ssh-keygen -f ${HOME}/.ssh/known_hosts -R ${IP}"
    echo
    if [ "${OS}" = "el5" ]; then
            sh -xc "IP=${IP} SSH_ARGS='-o HostKeyAlgorithms=+ssh-rsa' passwordless-ssh.exp"
    else
            sh -xc "IP=${IP} SSH_ARGS='' passwordless-ssh.exp"
    fi
    echo -e "\n# Test passwordless SSH :"
    sh -xc "ssh ${IP} id"

fi

else
  f_use
fi
