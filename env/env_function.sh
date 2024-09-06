
if [ -d ${FUNCTION_DIR} ]; then
  for i in ${FUNCTION_DIR}/f-*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i

  f-totel(){
    declare -F | grep 'declare -f f_'
    declare -F | grep 'declare -f f-'
  }
  #echo -e "\nTo list all functions :\nf-totel\n"
else
  ls -lhd ${FUNCTION_DIR}
fi
