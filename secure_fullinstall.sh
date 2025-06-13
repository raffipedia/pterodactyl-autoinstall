#!/bin/bash

clear
echo "==============================="
echo " Pterodactyl Auto Installer By Vendetta Ryuu"
echo "==============================="
echo "[0] Install Pterodactyl Panel (pakai SSL)"
echo "[1] Install Pterodactyl Wings"
echo "[x] Exit"
echo "==============================="
read -rp "Pilih opsi [0/1/x]: " opsi

if [[ $opsi =~ ^[xX]$ ]]; then
  echo "Keluar..."
  exit 0
fi

read -rp "Masukkan subdomain (contoh: panel.vendetta.my.id): " SUBDOMAIN
read -rp "Admin Email: " EMAIL
read -rp "Admin Username: " USERNAME
read -rp "Admin Password: " PASSWORD

if [[ $opsi == "0" ]]; then
  echo "[*] Memulai instalasi Panel di https://$SUBDOMAIN ..."
  curl -sSL https://raw.githubusercontent.com/pterodactyl/installer/master/install.sh | bash -s -- \
    --email "$EMAIL" \
    --username "$USERNAME" \
    --password "$PASSWORD" \
    --hostname "$SUBDOMAIN"

elif [[ $opsi == "1" ]]; then
  echo "[*] Memulai instalasi Wings..."
  apt update && apt install -y curl jq

  id -u pterodactyl &>/dev/null || useradd -m -d /etc/pterodactyl -s /bin/false pterodactyl

  mkdir -p /etc/pterodactyl
  curl -L https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 \
    -o /usr/local/bin/wings && chmod +x /usr/local/bin/wings

  echo "[✓] Wings berhasil diinstall. Berikut langkah selanjutnya:"
  echo "  1) Login ke Panel"
  echo "  2) Tambah Node di Panel"
  echo "  3) Salin konfigurasi Wings → paste ke /etc/pterodactyl/config.yml"
  echo "  4) Jalankan Wings: systemctl enable --now wings"

else
  echo "[!] Pilihan tidak valid."
  exit 1
fi
