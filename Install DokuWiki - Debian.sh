# Although this has a .sh filetype, it is intended to be followed as a guide rather than run as a script
# Replace all "mydomain.net" with your domain name
# By Greg Rowe April 2018

# Prereqs
apt-get update
apt-get upgrade -y

apt install nginx-full php7.0-fpm php7.0-xml php7.0-bcmath php7.0-curl php7.0-gd php7.0-gmp php7.0-intl php7.0-json php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-readline php7.0-zip php-pear php-xml -y

# Download & Unpack Dokuwiki
cd /root
wget http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz -O dokuwiki.tgz
tar -xvf dokuwiki.tgz

# Rename & Move Dokuwiki Dir
mv dokuwiki-*/ /var/www/mydomain.net

# Create a new Nginx server block in /etc/nginx/sites-available/mydomain.net
server {
  server_name mydomain.net www.mydomain.net;
  listen 80;
  listen [::]:80;
  listen 443 ssl;
  listen [::]:443 ssl;
  autoindex off;
  client_max_body_size 15M;
  client_body_buffer_size 128k;
  index index.html index.htm index.php doku.php;
  access_log  /var/log/nginx/mydomain.net-access.log;
  error_log  /var/log/nginx/mydomain.net-error.log;
  root /var/www/mydomain.net;

  location / {
    try_files $uri $uri/ @dokuwiki;
  }

  location ~ ^/lib.*\.(gif|png|ico|jpg)$ {
    expires 30d;
  }

  location = /robots.txt  { access_log off; log_not_found off; }
  location = /favicon.ico { access_log off; log_not_found off; }
  location ~ /\.          { access_log off; log_not_found off; deny all; }
  location ~ ~$           { access_log off; log_not_found off; deny all; }

  location @dokuwiki {
    rewrite ^/_media/(.*) /lib/exe/fetch.php?media=$1 last;
    rewrite ^/_detail/(.*) /lib/exe/detail.php?media=$1 last;
    rewrite ^/_export/([^/]+)/(.*) /doku.php?do=export_$1&id=$2 last;
    rewrite ^/(.*) /doku.php?id=$1 last;
  }

  location ~ \.php$ {
    try_files $uri =404;
    fastcgi_pass   unix:/run/php/php7.0-fpm.sock;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include /etc/nginx/fastcgi_params;
    fastcgi_param  QUERY_STRING     $query_string;
    fastcgi_param  REQUEST_METHOD   $request_method;
    fastcgi_param  CONTENT_TYPE     $content_type;
    fastcgi_param  CONTENT_LENGTH   $content_length;
    fastcgi_intercept_errors        on;
    fastcgi_ignore_client_abort     off;
    fastcgi_connect_timeout 60;
    fastcgi_send_timeout 180;
    fastcgi_read_timeout 180;
    fastcgi_buffer_size 128k;
    fastcgi_buffers 4 256k;
    fastcgi_busy_buffers_size 256k;
    fastcgi_temp_file_write_size 256k;
  }

  location ~ /(data|conf|bin|inc)/ {
    deny all;
  }

  location ~ /\.ht {
    deny  all;
  }
  location ~ /.well-known {
    allow all;
  }

}

# Create Symlink
ln -s /etc/nginx/sites-available/mydomain.net /etc/nginx/sites-enabled/mydomain.net

# Set Ownership
chown -R www-data:www-data /var/www/mydomain.net/
/etc/init.d/nginx restart

# LetsEncrypt
apt-get install certbot -y
sudo mkdir -p /usr/share/nginx/letsencrypt/.well-known/
letsencrypt-auto certonly -a webroot -w /usr/share/nginx/letsencrypt -d mydomain.net -d www.mydomain.net
certbot certonly -a webroot --webroot-path=/var/www/mydomain.net -d mydomain.net -d www.mydomain.net
