#!/bin/bash

# 1. Disable root login SSH
echo "Disabling root login for SSH..."
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# 2. Add allow firewall Linux CentOS port 22, 443, 80
echo "Configuring firewall rules..."
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload

# 3. Update system CentOS
echo "Updating the system..."
yum -y update

# 4. Create user CentOS
read -p "Enter new username: " username
adduser $username
passwd $username

# 5. Create hostname CentOS
read -p "Enter new hostname: " hostname
hostnamectl set-hostname $hostname

# 6. Set timezone Asia/Jakarta
echo "Setting timezone to Asia/Jakarta..."
timedatectl set-timezone Asia/Jakarta

echo "All tasks completed successfully."
