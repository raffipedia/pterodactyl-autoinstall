#!/bin/bash
set -e

echo "=========================================="
echo "  Pterodactyl Installer By Vendetta Ryuu"
echo "=========================================="
echo "[0] Install Pterodactyl Panel (pakai SSL)"
echo "[1] Install Pterodactyl Wings"
echo "[x] Exit"
echo "------------------------------------------"
read -p "Pilih opsi [0/1/x]: " pilihan

if [[ "$pilihan" == "0" ]]; then
  # PANEL INSTALL
  read -p "Masukkan subdomain Panel (contoh: panel.vendetta.my.id): " PANEL_DOMAIN
  read -p "Admin Email: " ADMIN_EMAIL
  read -p "Admin Username: " ADMIN_USER
  read -p "Admin Password: " ADMIN_PASS

  echo "[*] Menginstall Panel di https://$PANEL_DOMAIN ..."
  bash <(curl -s https://pterodactyl-installer.se/installers/panel.sh) \
    --fqdn "$PANEL_DOMAIN" \
    --email "$ADMIN_EMAIL" \
    --username "$ADMIN_USER" \
    --firstname "$ADMIN_USER" \
    --lastname "$ADMIN_USER" \
    --password "$ADMIN_PASS" \
    --ssl true \
    --wings false

elif [[ "$pilihan" == "1" ]]; then
  # WINGS INSTALL
  read -p "Masukkan subdomain Node (contoh: node.vendetta.my.id): " NODE_DOMAIN
  read -p "Masukkan subdomain Panel (contoh: panel.vendetta.my.id): " PANEL_SUB
  read -p "Masukkan Token Node (dari Panel): " NODE_TOKEN

  PANEL_URL="https://$PANEL_SUB"

  echo "[*] Menginstall Wings untuk $NODE_DOMAIN ..."
  bash <(curl -s https://pterodactyl-installer.se/installers/wings.sh) \
    --fqdn "$NODE_DOMAIN" \
    --panel-url "$PANEL_URL" \
    --token "$NODE_TOKEN"

elif [[ "$pilihan" =~ ^(x|X)$ ]]; then
  echo "Keluar. Terima kasih!"
  exit 0
else
  echo "Pilihan tidak valid."
  exit 1
fi
