read -r NET_DEV NET_IP <<< $(ip -4 -o addr show | awk '!/ lo / {print $2, $4}' | cut -d/ -f1 | head -n 1)
export NET_DEV NET_IP

