#!/bin/bash

clear
echo "==============================="
echo " Pterodactyl Auto By Vendetta Ryuu"
echo "==============================="
echo "[0] Install Panel + Wings (otomatis dengan SSL)"
echo "[1] Hanya Install Panel (manual mode)"
echo "[2] Hanya Install Wings"
echo "[x] Exit"
echo "==============================="
read -p "Pilih opsi [0/1/2/x]: " opsi

if [[ $opsi == "x" || $opsi == "X" ]]; then
    echo "Keluar..."
    exit 0
fi

if [[ $opsi == "0" ]]; then
    echo "[*] Menjalankan installer resmi..."
    bash <(curl -s https://pterodactyl-installer.se)

elif [[ $opsi == "1" ]]; then
    echo "[*] Menjalankan installer panel (mode manual)..."
    read -p "Masukkan subdomain (contoh: panel.domain.com): " SUBDOMAIN
    read -p "Admin Email: " EMAIL
    read -p "Admin Username: " USERNAME
    read -p "Admin Password: " PASSWORD

    curl -sSL https://pterodactyl-installer.se/install.sh | bash -s -- \
        --email "$EMAIL" \
        --username "$USERNAME" \
        --password "$PASSWORD" \
        --hostname "$SUBDOMAIN"

elif [[ $opsi == "2" ]]; then
    echo "[*] Install Wings saja..."
    curl -sSL https://pterodactyl-installer.se/install.sh | bash -s -- wings

else
    echo "[!] Pilihan tidak valid."
    exit 1
fi
