#!/bin/bash
# DESC: Change VM NEW_IP
# totel 20240913 Some info here
# totel 20240816 v2.0 Change input from Positional Parameters to Environment Variable Assignment (Inline Export)

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
  echo "
# USAGE:"
  cat << EOF | column -t
VM=el9-091 NEW_IP=192.168.122.91 $sc_name1
VM=el8-081 NEW_IP=192.168.122.81 $sc_name1
EOF
exit 1
}

if [ ! -z "${VM}" -a ! -z "${NEW_IP}" ]; then # if required variables are not empty
  f-marker VM=${VM} NEW_IP=${NEW_IP} $sc_name1 
else
  # Ensure required variables are defined
  echo "
FAILED: Empty variables found.
VM=${VM} | NEW_IP=${NEW_IP} "
  f_use
fi

VM=${VM} f-get-kvm-ip > /dev/null # returns $r_ip
if [ "${NEW_IP}" = "${r_ip}" ]; then
  echo -e "\nOld(${r_ip}) and new(${NEW_IP}) IP are the same. No change needed."
  exit
fi

set -e

f-cmd-verbose "ssh -o StrictHostKeyChecking=no ${r_ip} 'rm -v ~/change-ip.log*; (. ~/.bashrc; LOG=~/change-ip.log NEW_IP=${NEW_IP} change-ip.sh ) 2>&1 &> ~/change-ip.log.1 &' "
set +e

f-marker "Waiting for old IP(${r_ip}) to be down."
until !(ping -c 1 ${r_ip} > /dev/null); do
  printf "."
  sleep 5
done
echo -e "\nOld IP(${r_ip}) is now down."

f-marker "Waiting for new IP(${NEW_IP}) to be alive."
until (ping -c 1 ${NEW_IP} > /dev/null); do
  printf "."
  sleep 5
done
echo -e "\nNew IP(${NEW_IP}) is now reachable.\n"

f-cmd-verbose "ssh-keygen -f /home/totel/.ssh/known_hosts -R ${NEW_IP}"

f-marker "VM status"
vm-list.sh | egrep " ${VM} |^ Id"
