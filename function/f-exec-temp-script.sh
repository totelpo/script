f-exec-temp-script(){
fn_name=${FUNCNAME[0]}

fi_tmp_sh=$1
if [ $# -eq 1 ]; then
  f-marker $fn_name $@
	echo ; bash -xc "cat $fi_tmp_sh"
	if [ "$EXEC" = "y" ]; then
                echo; source $fi_tmp_sh
                bash -xc "sleep 2"
        else
                echo -e "\n[INFO] Temporary script $fi_tmp_sh was not executed. Set EXEC=y to execute.\n"
        fi
else
	cat << EOF
[USAGE] ${FUNCNAME[0]} SCRIPT
[USAGE] ${FUNCNAME[0]} /tmp/test.tmp.sh
EOF
fi
}

