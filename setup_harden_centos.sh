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
sed -i 's/^#PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config.d/01-permitrootlogin.conf
echo "Root login via SSH telah dinonaktifkan."
echo "PermitRootLogin no" >  /etc/ssh/sshd_config.d/01-permitrootlogin.conf

# Restart layanan SSH agar perubahan diterapkan
systemctl restart sshd

# Verifikasi apakah perubahan sudah diterapkan
if grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
    echo "Root login via SSH telah berhasil dinonaktifkan."
else
    echo "Gagal menonaktifkan root login via SSH."
fi



# Script untuk mengaktifkan SELinux dalam mode enforcing

echo "Memeriksa status SELinux saat ini..."
current_status=$(getenforce)

if [ "$current_status" == "Enforcing" ]; then
    echo "SELinux sudah dalam mode Enforcing."
    exit 0
fi

echo "Mengaktifkan SELinux dalam mode Enforcing untuk sementara..."
sudo setenforce 1
if [ $? -eq 0 ]; then
    echo "SELinux berhasil diubah ke mode Enforcing sementara."
else
    echo "Gagal mengaktifkan SELinux sementara. Pastikan SELinux terinstal."
    exit 1
fi

echo "Mengubah konfigurasi permanen untuk SELinux..."
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
if [ $? -eq 0 ]; then
    echo "Konfigurasi SELinux berhasil diatur permanen ke mode Enforcing."
else
    echo "Gagal mengubah konfigurasi SELinux. Periksa file /etc/selinux/config."
    exit 1
fi

echo "Status SELinux saat ini:"
getenforce

echo "SELinux berhasil diaktifkan dalam mode Enforcing. Restart diperlukan agar perubahan permanen berlaku."



# Script untuk start dan enable firewall di RHEL

echo "Memastikan firewalld terinstal..."
if ! command -v firewalld &> /dev/null; then
    echo "firewalld tidak ditemukan. Silakan install dengan 'sudo yum install firewalld'."
    exit 1
fi

echo "Memulai layanan firewalld..."
sudo systemctl start firewalld
if [ $? -eq 0 ]; then
    echo "Layanan firewalld berhasil dimulai."
else
    echo "Gagal memulai layanan firewalld."
    exit 1
fi

echo "Mengaktifkan firewalld agar berjalan otomatis saat boot..."
sudo systemctl enable firewalld
if [ $? -eq 0 ]; then
    echo "Layanan firewalld berhasil diaktifkan."
else
    echo "Gagal mengaktifkan layanan firewalld."
    exit 1
fi

echo "Memastikan status firewall..."
sudo systemctl status firewalld --no-pager

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
