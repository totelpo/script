#!/bin/bash
sc_name=$(basename $0)
sc_name1="${sc_name%.*}" # without extension name

sc_tmp=${TMPDIR}/${sc_name}.tmp

<<COMMENT
20240827 totel Add to github
COMMENT

if [ $# -lt 1 ]; then
  echo "
 DESC: Get photo info
USAGE: 
${sc_name} INPUT/s 
${sc_name} 2645-payapag/2645-010\*.jpg 
"
else 
  (
  echo "Filesize | Filename | WxH | DPI"
    for i in $@; do
      identify -format "`du -sh ${i}` | %w x %h | %x x %y\n" ${i} 2> /dev/null; 
    done | sed "s|$HOME|~|" | column -t | tr -s ' ' | sed 's/ / | /'  
  ) | column -t -s'|' -o'|'
fi
