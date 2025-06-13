#!/bin/bash

# Memastikan skrip dijalankan dengan hak akses root
if [ "$EUID" -ne 0 ]; then
  echo "Silakan jalankan skrip ini sebagai root."
  exit
fi

# Memperbarui sistem
echo "Memperbarui sistem..."
apt update && apt upgrade -y

# Menginstal dependensi
echo "Menginstal dependensi..."
apt install -y curl wget git unzip software-properties-common

# Menginstal PHP dan ekstensi yang diperlukan
echo "Menginstal PHP dan ekstensi..."
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-xml php8.1-mbstring php8.1-curl php8.1-zip php8.1-bcmath php8.1-json

# Menginstal Composer
echo "Menginstal Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Menginstal Node.js dan npm
echo "Menginstal Node.js dan npm..."
curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs

# Menginstal MariaDB
echo "Menginstal MariaDB..."
apt install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb

# Mengamankan instalasi MariaDB
echo "Mengamankan instalasi MariaDB..."
mysql_secure_installation

# Mengunduh dan menginstal Pterodactyl Panel
echo "Mengunduh dan menginstal Pterodactyl Panel..."
cd /var/www
git clone https://github.com/pterodactyl/panel.git pterodactyl
cd pterodactyl
composer install --no-dev --optimize-autoloader
cp .env.example .env
php artisan key:generate

# Mengonfigurasi database
echo "Mengonfigurasi database..."
# Anda perlu mengedit file .env untuk menambahkan detail database Anda
# Misalnya, Anda dapat menggunakan sed untuk mengganti nilai di .env
# sed -i 's/DB_DATABASE=homestead/DB_DATABASE=pterodactyl/' .env
# sed -i 's/DB_USERNAME=homestead/DB_USERNAME=root/' .env
# sed -i 's/DB_PASSWORD=secret/DB_PASSWORD=yourpassword/' .env

# Migrasi database
php artisan migrate --seed --force

# Menginstal Wings
echo "Menginstal Wings..."
cd /var/www
mkdir wings
cd wings
curl -Lo wings.tar.gz https://github.com/pterodactyl/wings/releases/latest/download/wings.tar.gz
tar -xzf wings.tar.gz
chmod +x wings
mv wings /usr/local/bin/

# Menjalankan Wings
echo "Menjalankan Wings..."
wings install

# Menampilkan pesan selesai
echo "Instalasi Pterodactyl Panel dan Wings selesai."
