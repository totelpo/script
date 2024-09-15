#!/bin/bash
# totel 20240914 

if [ ! -z "${OS}" ]; then
case ${OS} in
  el7|el8|el9)
    echo "${OS} is in the list." > /dev/null
    ;;
  u22|u24)
    echo "${OS} is not yet suppored."
    exit 1
    ;;
  deb11|deb12)
    echo "${OS} is not yet suppored."
    exit 1
    ;;
  *)
    echo "${OS} is not suppored."
    exit 1
    ;;
esac

else
  echo "Empty variable OS=${OS}."
  exit 1
fi
