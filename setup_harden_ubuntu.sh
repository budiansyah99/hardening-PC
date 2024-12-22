#!/bin/bash

# Disable root login via SSH

# Memeriksa apakah pengguna memiliki hak akses root (sudo)
if [ "$(id -u)" -ne "0" ]; then
    echo "Anda harus menjalankan script ini sebagai root atau dengan sudo."
    exit 1
fi

# Menonaktifkan root login di SSH
echo "Menonaktifkan root login melalui SSH..."

# Mengedit konfigurasi SSH untuk menonaktifkan login root
sed -i 's/^#PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
echo "Root login via SSH telah dinonaktifkan."

# Restart layanan SSH agar perubahan diterapkan
systemctl restart sshd

# Verifikasi apakah perubahan sudah diterapkan
if grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
    echo "Root login via SSH telah berhasil dinonaktifkan."
else
    echo "Gagal menonaktifkan root login via SSH."
fi
# Enable AppArmor
echo "Enabling AppArmor..."
systemctl enable apparmor
systemctl start apparmor
echo "AppArmor has been enabled."

# Create firewall rules for ports 22, 443, and 80
echo "Configuring firewall rules..."
ufw allow 22/tcp
ufw allow 443/tcp
ufw allow 80/tcp
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
