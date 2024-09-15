f-os-get-family() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "macOS"
    else
        echo "Unknown"
    fi
}
