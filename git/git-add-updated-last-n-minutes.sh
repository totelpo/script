#!/bin/bash
# Totel 20240911 Convert function to shell script then add to github
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
${sc_name1} script       1
${sc_name1} demo         1
EOF
}
if [ $# -eq 2 ]; then
  if [ ${p_minutes_ago} -gt 0 ]; then
    if [ -d ${v_repo_dir} ]; then
      cd ${v_repo_dir}
      v_files_changed0=$(find -type f -mmin -${p_minutes_ago} | grep -v '\.git' | sed 's|^\./||' | grep -v '\.swp$' | sort)
      v_files_changed1=$(echo ${v_files_changed0})  # complete path
      v_files_changed2="$(echo "${v_files_changed0}" | awk -F'/' '{ print $NF }')" # filename only 
      if [ -z "$v_files_changed1" ]; then 
        echo "No changed file/s found in ${v_repo_dir} in the last ${p_minutes_ago} minutes."
      else
        cat << EOF > ${v_out}
cd ${v_repo_dir}
(
set -e
git remote set-url origin git@github.com:totelpo/${p_github_repo}.git
git add ${v_files_changed1}
git commit -m "Add/Update `echo ${v_files_changed2}`"
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
