#!/bin/bash

# Define green color for OK and red color for NO
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# List of default hostnames to check
DEFAULT_HOSTNAMES=("ubuntu" "centos" "rhel" "debian" "localhost" "localdomain" "localhost.localdomain" "ubuntu20" "ubuntu18" "centos7" "centos8" "centos9")

# 1. Ensure root login is disabled
echo "Checking root login on SSH Configuration..."
if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
    echo -e "root login disabled ..... ${GREEN}OK${NC}"
else
    echo -e "root login disabled ..... ${RED}NO${NC}"
fi

# 2. Ensure AppArmor status is active and profiles are loaded
echo "Checking AppArmor status..."
if systemctl is-active --quiet apparmor; then
    echo -e "AppArmor enabled ..... ${GREEN}OK${NC}"
else
    echo -e "AppArmor enabled ..... ${RED}NO${NC}"
fi

echo "Checking loaded AppArmor profiles..."
apparmor_status | grep "profiles are loaded."
if [ $? -ne 0 ]; then
    echo -e "AppArmor profiles loaded ..... ${RED}NO${NC}"
else
    echo -e "AppArmor profiles loaded ..... ${GREEN}OK${NC}"
fi

# 3. Ensure UFW firewall is enabled and allows ports 22, 443, 80
echo "Checking Firewall status and firewall rules..."
ufw status | grep -qw "Status: active"
if [ $? -ne 0 ]; then
    echo -e "Firewall enabled ..... ${RED}NO${NC}"
else
    echo -e "Firewall enabled ..... ${GREEN}OK${NC}"
    for port in 22 443 80; do
        ufw status | grep -qw "$port/tcp"
        if [ $? -ne 0 ]; then
            echo -e "Port $port/tcp allowed ..... ${RED}NO${NC}"
        else
            echo -e "Port $port/tcp allowed ..... ${GREEN}OK${NC}"
        fi
    done
fi

# 4. Check the last system update
echo "Checking the last system update..."
last_update=$(grep 'End-Date' /var/log/apt/history.log | tail -1 | awk '{print $2}')

if [ -z "$last_update" ]; then
    echo -e "Unable to determine the last system update ..... ${RED}NO${NC}"
else
    last_update_time=$(date -d "$last_update" +%s 2>/dev/null)
    current_time=$(date +%s)
    time_diff=$((current_time - last_update_time))
    one_week=$((7 * 24 * 60 * 60))

    if [ $time_diff -gt $one_week ]; then
        echo -e "The system has been updated in the last week ..... ${RED}NO${NC}"
    else
        echo -e "The system has been updated in the last week ..... ${GREEN}OK${NC}"
    fi
fi

# 5. Ensure the user 'ubuntu' exists
echo "Checking if the user 'ubuntu' exists..."
if id -u ubuntu >/dev/null 2>&1; then
    echo -e "User 'ubuntu' exists ..... ${GREEN}OK${NC}"
else
    echo -e "User 'ubuntu' exists ..... ${RED}NO${NC}"
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
    echo -e "Current hostname: ${GREEN}$current_hostname${NC}}"
    echo -e "Hostname has Changed ..... ${GREEN}OK${NC}"
fi

# 7. Ensure timezone is set to Asia/Jakarta
echo "Checking timezone..."
current_tz=$(timedatectl show --property=Timezone --value)

if [ "$current_tz" == "Asia/Jakarta" ]; then
    echo -e "Timezone is set to Asia/Jakarta ..... ${GREEN}OK${NC}"
else
    echo -e "Timezone is set to Asia/Jakarta ..... ${RED}NO${NC}"
fi

echo "Check completed."
