
read -r NETWORK_DEVICE NETWORK_IP <<< $(ip -4 -o addr show | awk '!/ lo / {print $2, $4}' | cut -d/ -f1 | head -n 1)
CONNECTION_NAME=$(nmcli -t -f NAME,DEVICE connection show --active | grep "${NETWORK_DEVICE}" | cut -d ':' -f 1)
export  NETWORK_DEVICE NETWORK_IP CONNECTION_NAME


# Check if /etc/os-release exists
if [ -f /etc/os-release ]; then
    # Get the distribution name (pretty name)
    DISTRO_ID=$(grep "^ID=" /etc/os-release | cut -d '=' -f 2 | tr -d '"')

    # Get the full version ID (e.g., 20.04)
    VERSION_ID=$(grep "^VERSION_ID=" /etc/os-release | cut -d '=' -f 2 | tr -d '"')

    # Extract the major and minor version (splitting by dot)
    DISTRO_MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d '.' -f 1)
    DISTRO_MINOR_VERSION=$(echo "$VERSION_ID" | cut -d '.' -f 2)

    # Handle cases where there's no minor version (e.g., CentOS 7)
    if [ -z "$DISTRO_MINOR_VERSION" ]; then
        DISTRO_MINOR_VERSION="0"
    fi

    if [ "${DISTRO_ID}" = "ol" -o "${DISTRO_ID}" = "centos" ]; then
      OPERATING_SYSTEM=el${DISTRO_MAJOR_VERSION}
    elif [ "${DISTRO_ID}" = "ubuntu" ]; then
      OPERATING_SYSTEM=u${DISTRO_MAJOR_VERSION}
    fi
else
    DISTRO="Unknown"
    DISTRO_MAJOR_VERSION="Unknown"
    DISTRO_MINOR_VERSION="Unknown"
fi
export DISTRO DISTRO_MAJOR_VERSION DISTRO_MINOR_VERSION OPERATING_SYSTEM

v_interface=wlp0s20f3
v_ip=$(ip -4 addr show ${v_interface} | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
cat << EOF
# Upload files here from any device on the WI-FI network
http://192.168.1.16/upload/

EOF


