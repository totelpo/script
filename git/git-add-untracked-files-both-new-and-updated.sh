#!/bin/bash
# Totel 20240910 This will git add untracked files for both new and updated files
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

p_github_repo="$1";   p_github_repo=${p_github_repo:=default} # default value
p_minutes_ago="$2";   p_minutes_ago=${p_minutes_ago:=5} # default value
GITHUB_DIR=${GITHUB_DIR:=/github/totelpo}
v_repo_dir=${GITHUB_DIR}/${p_github_repo}
v_out=${sc_tmp}.sh
f_use(){
  cat << EOF
USAGE : 
${sc_name1} GITHUB_REPO  MINUTES_AGO
${sc_name1} script       60
${sc_name1} demo         1
EOF
}
if [ $# -eq 2 ]; then
  if [ ${p_minutes_ago} -gt 0 ]; then
    if [ -d ${v_repo_dir} ]; then
      cd ${v_repo_dir}
      v_untracked=$sc_tmp-untracked.list
      v_latest=$sc_tmp-latest-modified.list
      v_changed=$sc_tmp-changed.list
      git remote set-url origin git@github.com:totelpo/${p_github_repo}.git
      git status --untracked-files | grep -P '^\t' | sed 's/^\t//' | egrep -v '\.swp$|^modified:|/t/'    > ${v_untracked}
      find -type f -mmin -${p_minutes_ago} | egrep -v '\.swp$|\.\/\.git' | sed 's|^\./||' > ${v_latest}
      for i_file in $(cat $v_latest); do grep ${i_file} ${v_untracked}; done > ${v_changed}
      ls -lh $sc_tmp-*.list
      v_files_changed1=$(echo `cat ${v_changed}`)  # complete path
      if [ -z "$v_files_changed1" ]; then 
        echo "No changed file/s found in ${v_repo_dir} in the last ${p_minutes_ago} minutes."
      else
        cat << EOF > ${v_out}
cd ${v_repo_dir}
(
set -e
git remote set-url origin git@github.com:totelpo/${p_github_repo}.git
for i_file in ${v_files_changed1}; do
  git add \${i_file}
  git commit -m "Add \$(basename \${i_file})"
done
git push origin main
)
EOF
        sh -xc "cat ${v_out}"
        echo -e "\nWe need to execute :\nsh -x ${v_out}"
      fi
    else
      echo "Repo folder does not exists."
      ls -lhd ${v_repo_dir}
    fi
  else
    echo "p_minutes_ago must be greater than 0"
  fi
else
  echo "Check GITHUB_DIR=${GITHUB_DIR} for repo list"
  sh -xc "ls -lh ${GITHUB_DIR}"
  f_use
fi
