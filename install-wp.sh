#!/bin/bash
# this script will install wordpress

    ready="n"

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
    while [ $ready == "n" ]; do
        read -p "Are you ready to continue? [y/n]: " ready
        wait
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

        # rename wp-config-sample.php to wp-config.php
        mv wp-config-sample.php wp-config.php
        # delete the sample
        rm wp-config-sample.php
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

        # remove default file in /etc/nginx/sites-enabled/
        rm /etc/nginx/sites-enabled/default

        # restart nginx
        sudo systemctl restart nginx

        echo -e "${GREEN}Wordpress Installed!${ENDCOLOR}"
        echo -e "${GREEN}Please visit http://$domain to complete the wordpress installation${ENDCOLOR}"
    exit 0