#!/bin/bash

# This script will provide guidance on how to automate sys admin tasks.
# It will also provide a list of commands that can be used to automate
# tasks.

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[1;34m"
ENDCOLOR="\e[0m"



# create function that checks the directory structure
function checkdir() {
    # if the directory exists, continue
    if [ -d $1 ]; then
        # check if user has tree installed, if not install it
        if [ ! -f /usr/bin/tree ]; then
            echo -e "${RED}Tree is not installed, installing now...${ENDCOLOR}"
            sudo apt-get install tree -y
            wait
        fi
        echo -e "${GREEN}Directory $1 exists...${ENDCOLOR}"
        # so total number of files in the directory but not directories
        echo -e "${BLUE}Total number of files in $1: $(ls -l $1 | grep -v ^d | wc -l)${ENDCOLOR}"
        echo -e "${BLUE}Total number of directories in $1: $(ls -l $1 | grep ^d | wc -l)${ENDCOLOR}"
        #  use tree command to show the directory structure
        find $1 -maxdepth 1 -type d | while read -r dir
        # get the number of files in each directory and print it
        do
            echo -e "   ${BLUE}Total number of files in $dir: $(ls -l $dir | grep -v ^d | wc -l)${ENDCOLOR}"
        done
        # get owner of the directory
        echo -e "${BLUE}Owner of $1 is $(ls -ld $1 | awk '{print $3}')${ENDCOLOR}"
        # get group of the directory
        echo -e "${BLUE}Group of $1 is $(ls -ld $1 | awk '{print $4}')${ENDCOLOR}"
        # get permissions of the directory
        echo -e "${BLUE}Permissions of $1 is $(ls -ld $1 | awk '{print $1}')${ENDCOLOR}"
    else
        echo -e "${RED}Directory $1 does not exist...${ENDCOLOR}"
    fi
}


if [ $# -eq 0 ]; then
    echo "Usage: $0 [command]"
    echo "Commands:"
    echo "  help - print this help message"
    exit 0
fi

# create help that gives a list of commands
if [ $1 = "help" ]; then
    echo -e "${BLUE}Usage: $1 ${ENDCOLOR}"
    echo -e "${BLUE}Commands ${ENDCOLOR}"
    echo -e "${BLUE}  update-system - update all apt installed resouces and packages${ENDCOLOR}"
    echo -e "${BLUE}  install-wp - installs wordpress${ENDCOLOR}"
    echo -e "${BLUE}  directory-check - installs wordpress${ENDCOLOR}"
    echo -e "${BLUE}  email - takes \{email\} argument ${ENDCOLOR}"
    exit 0
fi

# if the first argument is "update-system", run the update system command
if [ $1 = "update-system" ]; then
    echo -e "${BLUE}Updating System...${ENDCOLOR}"
    sudo apt-get update && sudo apt-get upgrade -y
    wait
    echo -e "${GREEN}System Updated!${ENDCOLOR}"
    exit 0
fi

# if the first argument is "install-wp", run the install wordpress command
if [ $1 = "install-wp" ]; then
    sudo -i 
    wait
    echo -e "${BLUE}Installing Wordpress...${ENDCOLOR}"
    # first, lets install mariadb
    sudo apt-get install mariadb-server mariadb-client -y
    wait
    sudo systemctl enable mariadb
    wait
    sudo systemctl start mariadb
    wait

    # create a var called rootpass and set it to what the user types
    read -p "Enter a root password for mariadb: " rootpass
    wait
    sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('$rootpass') WHERE User = 'root'"
    wait
    # Kill the anonymous users
    sudo mysql -e "DROP USER IF EXISTS ''@'localhost'"
    # Because our hostname varies we'll use some Bash magic here.
    sudo mysql -e "DROP USER IF EXISTS ''@'$(hostname)'"
    # Kill off the demo database
    sudo mysql -e "DROP DATABASE IF EXISTS test"

    # create a database called wordpress
    sudo mysql -e "CREATE DATABASE wordpress"

    # create a user called wpuser and set it to what the user types
    read -p "We need to make a user for wordpress database, what do you want it to be called?: " wpuser
    read -p "now a password for the user ${wpuser}: " wpuserpass
    wait
    # create a user in mysql called wpuser
    sudo mysql -e "CREATE USER IF NOT EXISTS '$wpuser'@'localhost' IDENTIFIED BY '$wpuserpass'"
    mysql -e "GRANT ALL PRIVILEGES ON wordpress.* to '$wpuser'@'localhost'"
    sudo mysql -e "FLUSH PRIVILEGES"
    sudo mysql -e "exit"

    echo -e "${GREEN}MariaDB installed...${ENDCOLOR}"
    echo -e "${GREEN}Please Make Note Of These Details:${ENDCOLOR}"
    echo -e "${GREEN}Database Name: wordpress${ENDCOLOR}"
    echo -e "${GREEN}Database User: ${wpuser}${ENDCOLOR}"
    echo -e "${GREEN}Database Password: ${wpuserpass}${ENDCOLOR}"

    # wait until y is pressed
    while [ $ready != "y" ]; do
        read -p "Are you ready to continue? [y/n]: " ready
    done

        # install apache2
        sudo apt-get install nginx -y
        wait
        sudo systemctl enable nginx
        wait
        sudo systemctl start nginx
        wait 
        sudo add-apt-repository ppa:ondrej/php -y
        wait
        sudo apt update
        wait
        apt-get install php7.2 php7.2-cli php7.2-fpm php7.2-mysql php7.2-json php7.2-opcache php7.2-mbstring php7.2-xml php7.2-gd php7.2-curl php7.2-zip -y
        wait
        sudo systemctl enable php7.2-fpm
        wait
        sudo systemctl start php7.2-fpm
        wait
        mkdir -p /var/www/html/
        wait
        cd /var/www/html/
        wait
        wget https://wordpress.org/latest.tar.gz
        wait
        tar -xzvf latest.tar.gz
        wait
        rm latest.tar.gz
        wait
        mv wordpress/* .
        wait
        rm -rf wordpress
        wait
        chown -R www-data:www-data /var/www/html/
        wait
        chmod -R 755 /var/www/html/
        wait

        # open the wp-config.php 
        # and replace database_name_here with wordpress
        # and replace username_here with wpuser
        # and replace password_here with wpuserpasssudo sed -i "s/database_name_here/wordpress/g" /var/www/html/wp-config.php
        sudo sed -i "s/database_name_here/wordpress/g" /var/www/html/wp-config.php
        sudo sed -i "s/username_here/$wpuser/g" /var/www/html/wp-config.php
        sudo sed -i "s/password_here/$wpuserpass/g" /var/www/html/wp-config.php
        wait
        # open wp-config.php and remove anything with AUTH_KEY, SECURE_AUTH_KEY, LOGGED_IN_KEY, NONCE_KEY, AUTH_SALT, SECURE_AUTH_SALT, LOGGED_IN_SALT, and NONCE_SALT
        sudo sed -i '/AUTH_KEY/d' /var/www/html/wp-config.php
        sudo sed -i '/SECURE_AUTH_KEY/d' /var/www/html/wp-config.php
        sudo sed -i '/LOGGED_IN_KEY/d' /var/www/html/wp-config.php
        sudo sed -i '/NONCE_KEY/d' /var/www/html/wp-config.php
        sudo sed -i '/AUTH_SALT/d' /var/www/html/wp-config.php
        sudo sed -i '/SECURE_AUTH_SALT/d' /var/www/html/wp-config.php
        sudo sed -i '/LOGGED_IN_SALT/d' /var/www/html/wp-config.php
        sudo sed -i '/NONCE_SALT/d' /var/www/html/wp-config.php
        wait
        wget https://api.wordpress.org/secret-key/1.1/salt/ -O - | sudo tee -a /var/www/html/wp-config.php
        wait

        # ask for the domain name
        read -p "What is the domain name you want to use for wordpress? (example mackenziejames.com): " domain

        # create a file called wordpress.conf in /etc/nginx/sites-available/
        echo "server {
            listen 80 default_server;
            listen [::]:80 default_server;

            root /var/www/html;
            index index.php index.html index.htm index.nginx-debian.html;

            server_name $domain www.$domain;

            location / {
                try_files \$uri \$uri/ =404;
            }

            location = /robots.txt {
                    allow all;
                    log_not_found off;
                    access_log off;
            }

            location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.2-fpm.sock;
            }

            location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                    expires max;
                    log_not_found off;
            }

            location ~ /\.ht {
                deny all;
            }
        }" > /etc/nginx/sites-available/wordpress.conf

        # create a symlink to the file in /etc/nginx/sites-enabled/
        ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf

        # restart nginx
        sudo systemctl restart nginx

        echo -e "${GREEN}Wordpress Installed!${ENDCOLOR}"
        echo -e "${GREEN}Please visit http://$domain to complete the wordpress installation${ENDCOLOR}"
    exit 0
fi

if [ $1 = "check" ]; then
    # check if $2 is empty
    if [ -z "$2" ]; then
        echo -e "${RED}You must include a directory name (example /var/www/html)${ENDCOLOR}"
        exit 1
    fi
    wait
    checkdir "$2"
    exit 0
fi

if [ $1 = "email" ]; then
    shift
    if [ -z "$2" ]; then
        echo -e "${RED}You must include an email address${ENDCOLOR}"
        exit 1
    fi
    wait
    if [ $(dpkg-query -W -f='${Status}' mailutils 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo -e "${RED}mailutils is not installed${ENDCOLOR}"
        sudo apt install mailutils -y
        exit 1
    fi

    // get cpu useage
    cpu=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t", $(NF-2)}')
    ram=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
    disk=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}')

    mail -s 'VM Usage' -a From:Admin\<admin@example.com\>
    $2 <<< "CPU: $cpu
    RAM: $ram
    DISK: $disk"

    echo -e "${GREEN}Email Sent!${ENDCOLOR}"

fi