# This env file must be be called from ~/.bashrc
# totel 202408 
PATH_ORIG=$PATH
GITHUB_DIR=/github/totelpo
SCRIPT_DIR=${GITHUB_DIR}/script
PATH_MISC=${SCRIPT_DIR}/txt2html:${SCRIPT_DIR}/pix:${SCRIPT_DIR}/kvm:${SCRIPT_DIR}/ansible::${SCRIPT_DIR}/git
PATH=$PATH_ORIG:$PATH_MISC
if [ -z "${TMPDIR}" ]; then # Check if variable is empty
  if   [ -d ~/t ]; then
    TMPDIR=~/t
  elif [ -d /tmp ]; then
    TMPDIR=/tmp
  else
    echo "TMPDIR folders /tmp or ~/t does not exists."
  fi
fi
echo PATH=\$PATH_ORIG:$PATH_MISC | sed "s|:|\n:|g"
echo TMPDIR=$TMPDIR
export PATH PATH_ORIG PATH_MISC TMPDIR GITHUB_DIR SCRIPT_DIR 

ENV_DIR=${SCRIPT_DIR}/env
FUNCTION_DIR=${SCRIPT_DIR}/function
CONF_DIR=${SCRIPT_DIR}/conf
KVM_DIR=/vm/kvm
VM_OS_ADMIN=adminpo

export ENV_DIR FUNCTION_DIR CONF_DIR KVM_DIR VM_OS_ADMIN 

export MY_CNF_KVM=${CONF_DIR}/kvm-my.cnf

