f-cmd-verbose(){
if [ $# -eq 1 ]; then
	fp_cmd=$1
	vf_tmp_sh=${TMPDIR}/${FUNCNAME[0]}.tmp.sh
  f-marker ${FUNCNAME[0]}
	echo "+ $fp_cmd"
	echo "$fp_cmd" >  $vf_tmp_sh
	bash $vf_tmp_sh
else
	cat << EOF
[USAGE] ${FUNCNAME[0]} COMMAND
[USAGE] ${FUNCNAME[0]} 'ps aux > /tmp/ps.txt'
EOF
fi
}

