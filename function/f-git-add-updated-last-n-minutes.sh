f-git-add-updated-last-n-minutes(){
  fn_name=${FUNCNAME[0]}
  p_github_repo="$1";   p_github_repo=${p_github_repo:=default} # default value
  p_minutes_ago="$2";   p_minutes_ago=${p_minutes_ago:=5} # default value
  GITHUB_DIR=${GITHUB_DIR:=/github/totelpo}
  v_repo_dir=${GITHUB_DIR}/${p_github_repo}
  v_out=${TMPDIR}/${FUNCNAME[0]}-${p_github_repo}-tmp.sh
  f_use(){
    cat << EOF
USAGE : 
${fn_name} GITHUB_REPO  MINUTES_AGO
${fn_name} script       5
${fn_name} demo         5
EOF
  }
  if [ $# -eq 2 ]; then
    if [ ${p_minutes_ago} -gt 0 ]; then
      if [ -d ${v_repo_dir} ]; then
        cd ${v_repo_dir}
        v_files_changed_today=$(echo `find -type f -mmin -${p_minutes_ago} | grep -v '\.git' | sed 's|^\./||' | grep -v '\.swp$' | sort`)
        if [ -z "$v_files_changed_today" ]; then 
          echo "No changed file/s found in ${v_repo_dir} in the last ${p_minutes_ago} minutes."
        else
          cat << EOF > ${v_out}
git remote set-url origin git@github.com:totelpo/${p_github_repo}.git
git add ${v_files_changed_today}
git commit -m "Updated/created file/s via ${fn_name} n=${p_minutes_ago} : ${v_files_changed_today}"
git push origin main
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
}
