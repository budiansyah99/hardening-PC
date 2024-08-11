#!/bin/bash

# Konfigurasi
DISK="/dev/sdX"       # Ganti dengan nama disk fisik yang akan digunakan
VG_NAME="my_volume_group"  # Nama Volume Group
LV_NAME="my_logical_volume"  # Nama Logical Volume
LV_SIZE="10G"         # Ukuran Logical Volume
MOUNT_POINT="/mnt/my_mount"   # Titik mount untuk Logical Volume

# Fungsi untuk memeriksa kesalahan
check_error() {
    if [ $? -ne 0 ]; then
        echo "Terjadi kesalahan pada perintah: $1"
        exit 1
    fi
}

echo "Mulai proses pembuatan LVM..."

# Langkah 1: Membuat Partition di Disk untuk LVM (opsional, jika disk sudah ada, lewati bagian ini)
echo "Membuat partisi LVM pada disk $DISK..."
parted $DISK mklabel gpt
parted $DISK mkpart primary 0% 100%
parted $DISK set 1 lvm on
check_error "parted"

# Langkah 2: Membuat Physical Volume (PV)
echo "Membuat Physical Volume pada partisi $DISK..."
pvcreate ${DISK}1
check_error "pvcreate"

# Langkah 3: Membuat Volume Group (VG)
echo "Membuat Volume Group dengan nama $VG_NAME..."
vgcreate $VG_NAME ${DISK}1
check_error "vgcreate"

# Langkah 4: Membuat Logical Volume (LV)
echo "Membuat Logical Volume dengan nama $LV_NAME dan ukuran $LV_SIZE..."
lvcreate -n $LV_NAME -L $LV_SIZE $VG_NAME
check_error "lvcreate"

# Langkah 5: Membuat Sistem Berkas pada Logical Volume
echo "Membuat sistem berkas ext4 pada Logical Volume..."
mkfs.ext4 /dev/$VG_NAME/$LV_NAME
check_error "mkfs.ext4"

# Langkah 6: Membuat Titik Mount dan Memasang Logical Volume
echo "Membuat titik mount $MOUNT_POINT..."
mkdir -p $MOUNT_POINT
echo "Memasang Logical Volume ke $MOUNT_POINT..."
mount /dev/$VG_NAME/$LV_NAME $MOUNT_POINT
check_error "mount"

# Langkah 7: Mengatur Mount Otomatis saat Boot
echo "Menambahkan entri ke /etc/fstab untuk mount otomatis..."
echo "/dev/$VG_NAME/$LV_NAME $MOUNT_POINT ext4 defaults 0 2" >> /etc/fstab
check_error "fstab"

echo "Proses pembuatan LVM selesai!"
