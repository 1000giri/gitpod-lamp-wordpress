#!/bin/bash

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo mv ./wp-cli.phar /usr/local/bin/wp
sudo chmod +x /usr/local/bin/wp

cd public
wp core download --locale=ja
wp core config --dbname=wordpress --dbuser=root --dbpass='' --dbhost=localhost --dbprefix=wp_
wp db create
sed -i '1s/^/<?php $_SERVER["HTTPS"]="on"; $_ENV["HTTPS"]="ON"; ?>\n/' wp-config.php

