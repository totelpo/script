# This env file shall be called by every script to easily define temp files(output, logs, etc.)

p_all_input_parameters="$@"

# sc_name=$0 # must be declared from the parent script to gets its full path

sc_name1=$(basename $sc_name)   # scriptname
sc_name2="${sc_name1%.*}"       # scriptname without extension name
sc_dirname=$(dirname $sc_name)
sc_tmp=${TMPDIR}/$sc_name2-tmp

