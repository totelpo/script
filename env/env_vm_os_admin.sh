# This env file must be be called from ~/.bashrc
# totel 20240909 Set environment variable for VM_OS_ADMIN 
PATH_ORIG=$PATH
HOME=
SCRIPT_DIR=${HOME}/script
PATH_MISC=${SCRIPT_DIR}/bin
PATH=$PATH_ORIG:$PATH_MISC
if [ -z "${TMPDIR}" ]; then # Check if variable is empty
  if   [ -d ~/t ]; then
    TMPDIR=${HOME}/t
  elif [ -d /tmp ]; then
    TMPDIR=/tmp
  else
    echo "TMPDIR folders /tmp or ~/t does not exists."
  fi
fi
export PATH PATH_ORIG PATH_MISC TMPDIR SCRIPT_DIR 

ENV_DIR=${SCRIPT_DIR}/env
FUNCTION_DIR=${SCRIPT_DIR}/function
CONF_DIR=${SCRIPT_DIR}/conf

export ENV_DIR FUNCTION_DIR CONF_DIR

# If not running interactively, don't do anything as doing an echo command below make ansible fail
case $- in
    *i*) ;;
      *) return;;
esac
echo PATH=\$PATH_ORIG:$PATH_MISC | sed "s|:|\n:|g"
echo TMPDIR=$TMPDIR

