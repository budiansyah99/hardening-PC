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
