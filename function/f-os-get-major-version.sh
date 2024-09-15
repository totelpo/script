f-os-get-major-version() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "${VERSION_ID%%.*}"
    elif [[ "$(uname)" == "Darwin" ]]; then
        sw_vers -productVersion | cut -d '.' -f 1
    else
        echo "Unknown"
    fi
}
