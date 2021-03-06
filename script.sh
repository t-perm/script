#!/bin/bash
# A menu driven shell script sample template from mt 6
## ----------------------------------
# Step #1: Define variables
# ----------------------------------
EDITOR=vim
PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'



# function to display menus
show_menus() {
  echo -n -e  "----------------------------------------------------------------------------------"
  echo -e "                      ${RED}M A I N - M E N U${STD}"
  echo "----------------------------------------------------------------------------------"
  echo "1. Run apt-get update"
  echo "1.1 Run ssh-keygen"
  echo "2. Install zsh"
  echo "3. Install zsh theme and zsh-autosuggestions"
  echo "4. Install Nginx"
  echo "5. Install Php 7.2 and Composer"
  echo "6. Install Mysql"
  echo "7. Install let's encrypt ssl"
  echo "8. Let's encrypt helper"
  echo "9. Add vhost nginx"
  echo "Type quit or e or q to shut down script"
}

aptgetupdate() {
	echo -n -e "Running apt-get-update"
  apt-get update
}
zsh(){
  echo -n -e "Install zsh and "
  apt install zsh
  echo -n -e "Install oh-my-zsh"
  sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
  
  echo -n -e "\nInstall zsh and oh-my-zsh is done\n"
}
zsh_theme() {
  echo -n -e "Install zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  echo -n -e "Install zsh-powerlevel9k"
  git clone https://github.com/bhilburn/powerlevel9k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel9k
  # Change theme to powerlevel9k  
  sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel9k\/powerlevel9k\"/g' ~/.zshrc
  # Add zsh-autosuggestions
  sed -i 's/  git/  git zsh-autosuggestions/g' ~/.zshrc
  
  echo "
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time php_version ip)
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs )
POWERLEVEL9K_SHORTEN_DIR_LENGTH=4
DISABLE_AUTO_TITLE="true"
" >> ~/.zshrc
  
  echo -n -e "\nInstall zsh-powerlevel9k and zsh-autosuggestions is done. Please make sure add zsh-autosuggestions to plugins `vim ~/.zshrc`\n"
}

install_nginx(){
  echo -n -e "Install nginx"
  add-apt-repository -y ppa:nginx/development && apt-get update
  apt-get -y install nginx
  touch /etc/nginx/sites-available/gzip.conf
  echo "
gzip on;
gzip_disable "msie6";

gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_buffers 16 8k;
gzip_http_version 1.1;
gzip_types  text/plain
            text/css
            application/json
            application/javascript
            application/x-javascript
            text/html
            text/xml
            application/xml
            application/xml+rss
            text/javascript
            image/svg+xml
            application/vnd.ms-fontobject
            application/x-font-ttf
            font/opentype
            application/font-sfnt
            application/x-font-otf
            font/otf
            ;
" >> /etc/nginx/sites-available/gzip.conf
  echo -n -e "\nInstall nginx is done\n"
}

install_php_72(){
  echo -n -e "Install php7.2"

  add-apt-repository -y ppa:ondrej/php && apt-get update
  apt-get -y install php7.2
  apt-get -y install php7.2-fpm php7.2-curl php7.2-gd php7.2-json php7.2-mysql php7.2-sqlite3 php7.2-pgsql php7.2-bz2 php7.2-mbstring php7.2-soap php7.2-xml php7.2-zip
  
  echo -n -e "\nInstall php 7.2 is done\n"
  
  echo -n -e "\nInstall Composer\n"
  
  curl -sS https://getcomposer.org/installer | php
  chmod +x composer.phar
  mv composer.phar /usr/local/bin/composer
  composer -V
  
  echo -n -e "\nInstall Composer is done\n"
  
}

install_mysql(){
	echo -n -e "Install mysql"
	
	apt-get -y install mariadb-server
	service mysql stop
	mysql_install_db
	service mysql start
	mysql_secure_installation
	
	echo -n -e "\nInstall mysql is done\n"
}

add_vhost_nginx(){
	echo -n -e "Add  vhost nginx"
	
	read -p "Enter location store website example /var/www/html " HOST;
	read -p "Write the 1st level domain name without starting dot" DOMAIN;
	
	echo "Mkdir web - logs - ssl\n"
	
	mkdir -p $HOST.$DOMAIN/web
	mkdir -p $HOST.$DOMAIN/logs
	mkdir -p $HOST.$DOMAIN/ssl
	
	touch /etc/nginx/sites-available/$DOMAIN
	echo "
	server {
		listen 80;
		listen [::]:80;

		#listen 443 ssl http2;
		#listen [::]:443 ssl http2;
		#ssl_certificate /etc/letsencrypt/live/sample/fullchain.pem;
		#ssl_certificate_key /etc/letsencrypt/live/sample/privkey.pem;
		#ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
		#ssl_prefer_server_ciphers on;
		#ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;

		#ssl_session_cache shared:SSL:50m;
		#ssl_session_timeout 1d;
		#ssl_dhparam /etc/nginx/ssl/dhparam.pem;
		#add_header Strict-Transport-Security "max-age=31536000" always;

		root $HOST.$DOMAIN/web;
		index index.php index.html index.htm index.nginx-debian.html;


		access_log $HOST.$DOMAIN/logs/access.log;
		error_log $HOST.$DOMAIN/logs/error.log warn;
		server_name www.$DOMAIN, $DOMAIN;

		location / {
			try_files $uri $uri/ /index.php?$query_string;
		}
		location ~ \.php$ {
			include snippets/fastcgi-php.conf;
			fastcgi_pass unix:/run/php/php7.2-fpm.sock;
			fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
			fastcgi_param DOCUMENT_ROOT $realpath_root;
		}

		location ~ /\.ht {
				deny all;
		}

		location ~ /.well-known {
				allow all;
		}

	}" >> /etc/nginx/sites-available/$HOST.$DOMAIN
	
  ln -s /etc/nginx/sites-available/$HOST.$DOMAIN /etc/nginx/sites-enabled/$HOST.$DOMAIN
  nginx -t
  service nginx restart
  echo -n -e "\nAdd  vhost nginx is done\n"
}

install_let_s_encrypt_ssl(){
	echo -n -e "Install let's encrypt ssl"
	
	git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
	service nginx stop
	/opt/letsencrypt/certbot-auto certonly --standalone
	
	echo -n -e "Install ssl Nginx"
	
	mkdir /etc/nginx/ssl/
	openssl dhparam 2048 > /etc/nginx/ssl/dhparam.pem
	
	echo "\nopenssl dhparam 2048 > /etc/nginx/ssl/dhparam.pem is done\n"
}

let_s_encrypt_ssl_helper(){
	echo -n -e "To auto renew ssl please add: crontab 30 2 * * * /opt/letsencrypt/certbot-auto renew --pre-hook 'service nginx stop' --post-hook 'service nginx start'"	
	echo -n -e "To add more domain please run: /opt/letsencrypt/certbot-auto -d lis_domain Example aa.com,bb.com\n"
}

ssh_keygen(){
  ssh-keygen -t rsa -b 2048
}

read_options(){
  local choice
  echo " "
  read -p "Enter choice:" choice
  case $choice in
    1) aptgetupdate ;;
    1.1) ssh_keygen ;;
    2) zsh ;;
    3) zsh_theme ;;
    4) install_nginx ;;
    5) install_php_72 ;;
    6) install_mysql ;;
    7) install_let_s_encrypt_ssl ;;
    8) let_s_encrypt_ssl_helper ;;
    9) add_vhost_nginx ;;
    quit)clear && exit 0;;
    e)clear && exit 0;;
	q)clear && exit 0;;
    *) echo -e "${RED}Can not match with any selected${STD}" && sleep 1
  esac
}
# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
  show_menus
  read_options
done
