#!/bin/bash

# Disable root login via SSH
echo "Disabling root login via SSH..."
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd
echo "Root login via SSH has been disabled."

# Enable AppArmor
echo "Enabling AppArmor..."
systemctl enable apparmor
systemctl start apparmor
echo "AppArmor has been enabled."

# Create firewall rules for ports 22, 443, and 80
echo "Configuring firewall rules..."
ufw allow 22
ufw allow 443
ufw allow 80
ufw enable
echo "Firewall rules for ports 22, 443, and 80 have been configured."

# Update system packages
echo "Updating system packages..."
apt update && apt upgrade -y
echo "System packages have been updated."

# Create a new user 'ubuntu'
echo "Creating new user 'ubuntu'..."
adduser --disabled-password --gecos "" ubuntu
echo "User 'ubuntu' has been created."

# Set hostname
read -p "Enter new hostname: " new_hostname
echo "Setting hostname to $new_hostname..."
hostnamectl set-hostname "$new_hostname"
echo "Hostname has been set to $new_hostname."

# Set timezone to Asia/Jakarta
echo "Setting timezone to Asia/Jakarta..."
timedatectl set-timezone Asia/Jakarta
echo "Timezone has been set to Asia/Jakarta."

echo "All steps have been successfully completed!"
