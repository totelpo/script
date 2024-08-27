#!/bin/bash

# 2021-12-16 Totel Create a HTML file from text file
# 2024-08-24 Totel Remove <!DOCTYPE html> as the first line of the output because it disables the padding in <pre> tag
#                  Add TMPDIR
#                  Add menu using iframe

sc_name=$(basename $0)   # script name
sc_name1="${sc_name%.*}" # without extenstion
sc_dirname=$(dirname $0)

if   [ -d ~/t ]; then 
  TMPDIR=~/t
elif [ -d /tmp ]; then 
  TMPDIR=/tmp
else 
  echo "TMPDIR folders /tmp or ~/t does not exists."
  exit 1
fi


v_sample=${TMPDIR}/txt2html-sample.txt
v_sample_bug=${TMPDIR}/txt2html-sample-bug-report.txt

f_use() {
# USAGE: 
  echo "
$sc_name TEXT_FILE        OUT_DIR    DOC_TYPE MENU CSS_STYLE
$sc_name ${v_sample}      ~/t        doc
$sc_name ${v_sample_bug}  ~/t        bug

" | sed "s|$HOME|~|g" | column -t

echo "NOTE : OUT_DIR must be inside the user's HOME directory to avoid 'File not found' issue while reading the output with Firefox/Chromium using the file protocol."

cat << EOF > ${v_sample_bug}
/ Sample Bug Report
some text
/ 1 | DESCRIPTION
some text
/ 2 | HOW TO REPEAT
some text
/ 2.1 | Tested on 
some text
/ 2.2 | Prepare schema
some text
/ 2.3 | Add more data
some text
/ 3 | SUGGESTED FIX
some text
EOF

cat << EOF > ${v_sample}
/ Some Title
some text
/ 1 | Apache-Hadoop-Installation
some text
some text very long texttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
/ 2 | Topology
some text
/ 2.1 | Master-Nodes
some text
/ 2.2 | Slave-Nodes
some text
/ 3 | Prerequisites
some text
/ 3.1 | Passwordless-SSH-Root
some text
/ 3.1 | Java
some text
/ 3.2 | Create-Users
some text
/ 3.3 | Passwordless-SSH
some text
/ A | References
some text
/ B | Document Version
some text
EOF
ls -lh ${TMPDIR}/txt2html-sample*.txt
exit
}

f_exit_status()     { if [ $? -gt 0 ]; then echo -e "\nERROR ENCOUNTERED ....\n"; exit; fi; }

if [ $# -gt 1 ]; then
  p_text_file="$1"; p_text_file=${p_text_file:=hadoop-1.0-install.txt} # default value
  p_out_dir="$2"; p_out_dir=${p_out_dir:=~/t} # default value
  p_doc_type="$3"; p_doc_type=${p_doc_type:=doc} # default value
  p_menu_html="$4"; p_menu_html=${p_menu_html:=${sc_dirname}/menu/sample-menu-via-nav.html} # default value
  p_style_css="$5"; p_style_css=${p_style_css:=${sc_dirname}/css/styles.css} # default value

  ls -lh "$p_text_file" > /dev/null
  f_exit_status
  ls -lhd $p_out_dir > /dev/null
  f_exit_status

  mkdir -p ${p_out_dir}/{menu,css}
  cp -nv $p_menu_html ${p_out_dir}/menu/menu.html 
  cp -nv $p_style_css ${p_out_dir}/css/styles.css 

  v_tmp=${TMPDIR}/$sc_name1.tmp
  v_out=$p_out_dir/$(basename "$p_text_file").tmp.html

grep '^/ ' "$p_text_file" | sed 's|^/ ||' > $v_tmp
sed -n '1p' $v_tmp > $v_tmp.1
sed    '1d' $v_tmp > $v_tmp.2

f_main () {
  v_list_type=$1        # ul = unordered list | ol = ordered list
  v_type=$2

  if [ "$v_type" = "body" ]; then
    v_content_type=h3
  elif [ "$v_type" = "table-of-contents" ]; then
    v_content_type=li
  else
    v_content_type=li
  fi

  f_indention(){
    p_1=$1
    for ((l=1; l<=$(((p_1*4))); l++)); do  printf -- ' '; done  # print indention
}
  f_indention1(){
    for ((l=1; l<=$(((v_nf1-1)*4)); l++)); do  printf -- ' '; done  # print indention
}
  f_indention2(){
    for ((l=1; l<=$(((v_nf2-1)*4)); l++)); do  printf -- ' '; done  # print indention
}

f_grep_xml() {
  echo "$w" | grep '.xml'
  v_exit_status=$?
}
f_content() {
  if [ "$v_content_type" = "h2" -o "$v_content_type" = "h3" ]; then
    if [ $p_doc_type = bug ]; then
      echo ' <a id="'$c2_hyphen_only'" ">'$c2_space_only'</a>'
    else
      echo $i' <a id="'$c2_hyphen_only'" href="#toc-'$c2_hyphen_only'">'$c2_space_only'</a>'
    fi

    if [ $v_nf1 -eq 1 ]; then
      echo "</$v_content_type>"
    fi

    f_grep_xml > /dev/null
    if [ $v_exit_status -eq 0 ]; then
      v_pre=xmp
    else
      v_pre=pre
    fi
    echo "
<p></p>
<ul>
<li>
<p></p>
<$v_pre>"

  awk -v n=$v_counter '/^\/ /{l++} l>n{exit} l==n' "$p_text_file" | sed '1d' | sed -e :a -e '/./,$!d; /^\n*$/{$d;N;};/\n$/ba'   # sed delete first line and leading/trailing blank lines

echo "</$v_pre>
</li>
</ul>
"
  else 
    echo $i' <a id="toc-'$c2_hyphen_only'" href="'$c2_hash_tag'">'$c2_space_only'</a>'
  fi
}

f_1(){
  if [ $v_nf1 -gt $v_nf2 ]; then
      f_indention1
      echo "<$v_list_type>"
      f_indention1
      echo "<li>"
  elif [ $v_nf1 -lt $v_nf2 ]; then
        v_diff=1
        for ((j=1; j<=$((v_nf2-v_nf1)); j++)); do
            f_indention $((v_nf2-v_diff))
            echo "</$v_list_type>"
            v_diff=$((v_diff+1))
        done
    if [ $v_nf1 -eq 1 ]; then
      echo "<$v_content_type>"
    else
      f_indention1
      echo "<li>"
    fi
  elif [ $v_nf1 -eq $v_nf2 ]; then
    if [ $v_nf1 -eq 1 ]; then
      echo "<$v_content_type>"
    else
      f_indention1
      echo "<li>"
    fi
  fi
}

f_2_nf1_1() {
  if [ "$v_content_type" = "li" ]; then
    echo "</$v_content_type>"
  fi
}

f_2(){
  if [ $v_nf1 -gt $v_nf2 ]; then    # column number of current value is greater than the  column number of previous value
      f_indention1
      echo "</li>"
  elif [ $v_nf1 -lt $v_nf2 ]; then  # column number of current value is less    than the  column number of previous value
    i2_nf1=`echo $i2 | cut -d. -f1-$v_nf1`
    if [ $v_nf1 -eq 1 ]; then
     #echo # "</$v_content_type>"
     f_2_nf1_1
    else
      if [ "$i2_nf1" == "$i1" ]; then
        echo "</li>"
      else
f(){
        v_diff=1
        for ((j=1; j<=$((v_nf2-v_nf1)); j++)); do
            f_indention $((v_nf1-v_diff))
            echo "</li>"
            v_diff=$((v_diff+1))
        done
}
    if [ $v_nf1 -eq 1 ]; then
      f_2_nf1_1
    else
      f_indention1
      echo "</li>"
    fi
      fi
    fi
  elif [ $v_nf1 -eq $v_nf2 ]; then
    if [ $v_nf1 -eq 1 ]; then
      f_2_nf1_1
    else
      f_indention1
      echo "</li>"
    fi
  fi
}

v_nf2=1

v_counter=1
cat $v_tmp.2 | while read w; do
  v_counter=$((v_counter+1));
  i=`echo "$w" | awk -F"|" '{ print $1 }'`
  c2_space_only=` echo "$w" | awk -F"|" '{ print $2 }' | sed 's/://; s/  */ /g; s/^ //; s/ $//'`   # plus delete multiple spaces and leading ang trailing space
  c2_hyphen_only=`echo $c2_space_only  | sed 's/ /-/g'`
  c2_hash_tag=`   echo $c2_hyphen_only | sed 's/^/#/'`
  v_nf1=`echo $i | awk -F. '{ print NF }'`
  v_i1=`echo $i | awk -F. '{ OFS=FS; $NF=""; print $0 }' | sed 's/\.$//'`





  f_1
  f_content
  f_2

  v_nf2=$v_nf1
  v_i2=$v_i1
  i2=$i
done
v_nf1=1
f_1

}

(
v_title=`cat $v_tmp.1`
f_introduction(){
v_counter=1
awk -v n=$v_counter '/^\/ /{l++} l>n{exit} l==n' "$p_text_file" | sed '1d' | sed -e :a -e '/./,$!d; /^\n*$/{$d;N;};/\n$/ba'   # sed delete first line and leading/trailing blank lines
}

echo "
<html lang='en-US'>
<head>
  <!-- XXX Wiki by TotelPo 2021-06-02 -->
  <title>$v_title</title>
  <link href='css/styles.css' rel='stylesheet' type='text/css' />
</head>
<body>

<!-- Embed the menu using an iframe -->
<iframe src='menu/menu.html'></iframe>

<br>
"

echo '
<div style="border: 1px outset black; padding:0 10px;"> <!-- TABLE OF CONTENTS -->
<h2>'$v_title'</h2>
<pre>'

f_introduction

echo '
</pre>

<h2>Table of Contents</h2>
<ul>
'

f_main ul table-of-contents

echo "
</ul>
</div> <!-- TABLE OF CONTENTS -->

<p></p>
"

echo '<div style="border: 1px outset black; padding:0 10px;"> <!-- BODY -->'

f_main ul body
echo '<div> <!-- BODY -->'

) > $v_out

#ls -lh $v_tmp* $v_out
ls -lh $v_out


else
  
  f_use

fi

echo
#ls -lhd $sc_dirname
#ls -lh  $sc_dirname/{wiki.css,menu.html}

