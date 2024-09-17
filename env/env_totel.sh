# This env file must be be called from ~/.bashrc
# totel 202408 
# totel 20240911 Set PS1 and PROMPT_COMMAND
PS1_ORIG="${PS1}"
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '         # shell prompt
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}:$(basename $(pwd))\007"'   # tab title
PATH_ORIG=$PATH
GITHUB_DIR=/github/totelpo
SCRIPT_DIR=${GITHUB_DIR}/script
PATH_MISC=${SCRIPT_DIR}/txt2html:${SCRIPT_DIR}/pix:${SCRIPT_DIR}/kvm:${SCRIPT_DIR}/ansible:${SCRIPT_DIR}/git:${SCRIPT_DIR}/bin
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
export PATH PATH_ORIG PATH_MISC TMPDIR GITHUB_DIR SCRIPT_DIR 
EXEC=n
export EXEC

ENV_DIR=${SCRIPT_DIR}/env
FUNCTION_DIR=${SCRIPT_DIR}/function
CONF_DIR=${SCRIPT_DIR}/conf
KVM_DIR=/vm/kvm
export ENV_DIR FUNCTION_DIR CONF_DIR KVM_DIR 

VM_OS_ADMIN=osadmin
VM_OS_ADMIN_PASS=abc123
VM_DOMAIN=localdomain
VM_KEY=id_rsa_kvm
VM_KEY_FILE=${HOME}/.ssh/${VM_KEY}
export VM_OS_ADMIN VM_OS_ADMIN_PASS VM_DOMAIN VM_KEY VM_KEY_FILE 

ANSIBLE_HOSTS_FILE=/etc/ansible/hosts
ANSIBLE_YAML_DIR=${SCRIPT_DIR}/ansible/yaml
export ANSIBLE_HOSTS_FILE ANSIBLE_YAML_DIR

# script marker
TERM=xterm
MARKER_WIDTH="${MARKER_WIDTH:=$((`tput cols`*95/100))}"
MARKER=`eval "printf '#%.0s' {1..$MARKER_WIDTH}"`
export TERM MARKER_WIDTH MARKER

read -r NET_DEV NET_IP <<< $(ip -4 -o addr show | awk '!/ lo / {print $2, $4}' | cut -d/ -f1 | head -n 1)
export NET_DEV NET_IP

export MY_CNF_KVM=${CONF_DIR}/kvm-my.cnf

# If not running interactively, don't do anything as doing an echo command below make ansible and rsync fail
case $- in
    *i*) ;;
      *) return;;
esac
echo PATH=\$PATH_ORIG:$PATH_MISC | sed "s|:|\n:|g"
echo TMPDIR=$TMPDIR

