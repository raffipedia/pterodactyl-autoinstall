#!/bin/bash

LOGFILE="/root/pteroinstall.log"
exec > >(tee -i "$LOGFILE") 2>&1

# --- Fungsi: Konfirmasi ---
function confirm() {
  read -rp "$1 [y/n]: " input
  [[ "$input" == "y" || "$input" == "Y" ]]
}

# --- Cek root ---
if [[ $EUID -ne 0 ]]; then
  echo "[!] Jalankan script ini sebagai root!"
  exit 1
fi

# --- Cek OS ---
OS=$(grep '^ID=' /etc/os-release | cut -d= -f2)
VERSION=$(grep 'VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
if [[ "$OS" != "ubuntu" ]] || ([[ "$VERSION" != "20.04" ]] && [[ "$VERSION" != "22.04" ]]); then
  echo "[!] Hanya mendukung Ubuntu 20.04 atau 22.04!"
  exit 1
fi

echo "[✓] OS: Ubuntu $VERSION"
echo "[✓] Root user terdeteksi"

# --- Update Sistem ---
if confirm "Update sistem dan install dependency utama (nginx, mariadb, redis, php)?"; then
  apt update && apt upgrade -y
  apt install -y curl wget zip unzip tar nginx mariadb-server redis-server \
    php php-cli php-mysql php-gd php-mbstring php-xml php-bcmath php-curl php-zip \
    php-fpm php-tokenizer php-common php-redis php-mysqlnd php-intl php-imap \
    software-properties-common git composer
else
  echo "[!] Lewati tahap ini."
fi

# --- Konfigurasi MariaDB ---
if confirm "Setup database untuk Pterodactyl?"; then
  DB_NAME="panel"
  DB_USER="pterodactyl"
  DB_PASS=$(openssl rand -base64 16)
  mysql -e "CREATE DATABASE $DB_NAME;"
  mysql -e "CREATE USER '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';"
  mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'127.0.0.1';"
  mysql -e "FLUSH PRIVILEGES;"
  echo "[✓] Database '$DB_NAME' dan user '$DB_USER' berhasil dibuat."
else
  echo "[!] Lewati konfigurasi database."
fi

# --- Install Panel ---
if confirm "Lanjut install Pterodactyl Panel?"; then
  mkdir -p /var/www/
  cd /var/www/ || exit
  git clone https://github.com/pterodactyl/panel.git --branch=v1.11.4 --single-branch
  cd panel || exit
  cp .env.example .env
  composer install --no-dev --optimize-autoloader
  php artisan key:generate --force

  # Ganti ENV otomatis (kalau DB disetup)
  if [[ -n "$DB_PASS" ]]; then
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env
  fi

  php artisan migrate --seed --force

  echo "[✓] Panel berhasil diinstal. Jalankan php artisan p:user:make untuk membuat admin."
else
  echo "[!] Lewati install panel."
fi

# --- Setup Nginx ---
if confirm "Setup Nginx untuk panel (HTTP)?"; then
  read -rp "Masukkan domain/subdomain (cth: panel.domain.com): " DOMAIN
  cat > /etc/nginx/sites-available/pterodactyl <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/panel/public;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
  ln -s /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/
  nginx -t && systemctl reload nginx
  echo "[✓] Nginx telah dikonfigurasi untuk $DOMAIN"
else
  echo "[!] Lewati konfigurasi Nginx."
fi

# --- Install Wings ---
if confirm "Lanjut install Wings (backend)?"; then
  curl -sSL https://get.docker.com/ | CHANNEL=stable bash
  systemctl enable --now docker

  mkdir -p /etc/pterodactyl
  cd /etc/pterodactyl || exit
  curl -Lo wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
  chmod +x wings

  cat > /etc/systemd/system/wings.service <<EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
ExecStart=/etc/pterodactyl/wings
Restart=on-failure
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reexec
  systemctl enable --now wings

  echo "[✓] Wings berhasil dipasang dan dijalankan."
else
  echo "[!] Wings tidak diinstal."
fi

echo "✅ SEMUA SELESAI! Log tersimpan di: $LOGFILE"
