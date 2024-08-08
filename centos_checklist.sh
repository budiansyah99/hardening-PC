#!/bin/bash

# Define green color for OK and red color for NO
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# List of default hostnames to check
DEFAULT_HOSTNAMES=("ubuntu" "centos" "rhel" "debian" "localhost" "localdomain" "localhost.localdomain" "ubuntu20" "ubuntu18" "centos7" "centos8" "centos9")

# 1. Ensure root login is disabled
echo "Checking root login on SSH Configuration..."
if sudo grep -q "^PermitRootLogin no" /etc/ssh/sshd_config.d/01-permitrootlogin.conf; then
    echo -e "root login disabled ..... ${GREEN}OK${NC}"
else
    echo -e "root login disabled ..... ${RED}NO${NC}"
fi

# 2. Ensure SELinux status is enabled and enforcing
echo "Checking SELinux status..."
selinux_status=$(sudo sestatus | grep "SELinux status:" | awk '{print $3}')
selinux_mode=$(sudo sestatus | grep "Current mode:" | awk '{print $3}')

if [ "$selinux_status" == "enabled" ]; then
    echo -e "SELinux status: enabled ..... ${GREEN}OK${NC}"
else
    echo -e "SELinux status: enabled ..... ${RED}NO${NC}"
fi

if [ "$selinux_mode" == "enforcing" ]; then
    echo -e "SELinux mode: enforcing ..... ${GREEN}OK${NC}"
else
    echo -e "SELinux mode: enforcing ..... ${RED}NO${NC}"
fi

# 3. Ensure firewalld is enabled and allows ports 22, 443, 80
echo "Checking firewalld status and firewall rules..."
if sudo systemctl is-active --quiet firewalld; then
    echo -e "Firewall enabled ..... ${GREEN}OK${NC}"
else
    echo -e "Firewall enabled ..... ${RED}NO${NC}"
fi

for port in 22 443 80; do
    sudo firewall-cmd --list-ports | grep -qw "$port/tcp"
    if [ $? -ne 0 ]; then
        echo -e "Port $port/tcp allowed ..... ${RED}NO${NC}"
    else
        echo -e "Port $port/tcp allowed ..... ${GREEN}OK${NC}"
    fi
done

# 4. Get the last update time
echo "Checking the last system update..."
last_update=$(sudo dnf check-update | grep 'Last metadata expiration check:' | sed 's/Last metadata expiration check: .* on //;s/ [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.*//')
if [ -z "$last_update" ]; then
    echo -e "Unable to determine the last system update ..... ${RED}NO${NC}"
else
    last_update_time=$(date -d "$(echo $last_update | awk '{print $7, $6, $8, $9}')" +%s 2>/dev/null)
    current_time=$(date +%s)
    time_diff=$((current_time - last_update_time))
    one_week=$((7 * 24 * 60 * 60))

    if [ $time_diff -gt $one_week ]; then
        echo -e "The system has not been updated in the last week ..... ${RED}NO${NC}"
    else
        echo -e "The system has been updated in the last week ..... ${GREEN}OK${NC}"
    fi
fi

# 5. Ensure the user 'centos' exists
echo "Checking if the user 'centos' exists..."
if sudo id -u centos >/dev/null 2>&1; then
    echo -e "User 'centos' exists ..... ${GREEN}OK${NC}"
else
    echo -e "User 'centos' exists ..... ${RED}NO${NC}"
fi

# 6. Check hostname
echo "Checking hostname..."
current_hostname=$(hostname)
hostname_check=0

for default_hostname in "${DEFAULT_HOSTNAMES[@]}"; do
    if [[ "$current_hostname" == *"$default_hostname"* ]]; then
        hostname_check=1
        break
    fi
done

if [ $hostname_check -eq 1 ]; then
    echo -e "Current hostname: ${RED}$current_hostname${NC}"
    echo -e "Hostname has Changed ..... ${RED}NO${NC}"
else
    echo -e "Current hostname: ${GREEN}$current_hostname${NC}"
    echo -e "Hostname has Changed ..... ${GREEN}OK${NC}"
fi

# 7. Ensure timezone is set to Asia/Jakarta
echo "Checking timezone..."
current_tz=$(sudo timedatectl show --property=Timezone --value)

if [ "$current_tz" == "Asia/Jakarta" ]; then
    echo -e "Timezone is set to Asia/Jakarta ..... ${GREEN}OK${NC}"
else
    echo -e "Timezone is set to Asia/Jakarta ..... ${RED}NO${NC}"
fi

echo "Check completed."
