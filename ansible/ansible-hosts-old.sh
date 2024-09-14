#!/bin/bash
# totel 20240914 This generates ansible host file

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

if [ -z "${ANSIBLE_HOSTS_FILE}" ]; then 
  # Ensure required variables are not empty (that is already declared in bashrc).
  echo -e "
FAILED: Empty variables found.
ANSIBLE_HOSTS_FILE=${ANSIBLE_HOSTS_FILE}
"
  exit 1
fi

f-marker $sc_name1 $@

v_conf=${ANSIBLE_HOSTS_FILE}.old
(
ansible-hosts-common.sh
cat << EOF

[template]
s080
s090

[mysql]
s101
s102
s103

[ps]
s111
s112
s113

[mariadb]
s121
s122
s123

[mgr]
s131
s132
s133

[pxc]
s141
s142
s143

[galera]
s151
s152
s153

EOF
) > $v_conf
cp -v $v_conf ${ANSIBLE_HOSTS_FILE}

