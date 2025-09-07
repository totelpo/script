#!/bin/bash
sc_name=$(basename $0)

<<COMMENT
20240827 totel Add to github
COMMENT

if [ $# -lt 1 ]; then
  echo "
 DESC: Get photo info
USAGE: 
HIDE=-H5 ${sc_name} INPUT/s 
HIDE=-H5 ${sc_name} 2645-payapag/2645-010\*.jpg 
"
else 
  (
  echo "Filesize|Filename|Width|Height|DPI"
    for filename in $@; do
      identify -format "`du -sh ${filename}`|%w|%h|%xx%y\n" ${filename}; 
    done | sed "s|$HOME|~|" | column -t | tr -s ' ' | sed 's/ /|/'  
  ) | awk -F'|' 'NR==1 { for(i=1;i<=NF;i++) printf i (i==NF ? "\n" : "|") } {print}' `# Add column numbers` \
    | column -t -s'|' -o'|' ${HIDE}
fi
