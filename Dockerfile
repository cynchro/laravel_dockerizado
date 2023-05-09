FROM php:8.0-apache

RUN apt-get update && \
    apt-get install -y git zip unzip && \
    docker-php-ext-install pdo_mysql

WORKDIR /var/www/html

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./app/ ./

# Configurar Apache
COPY ./apache/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN sed -i 's/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10M/' /usr/local/etc/php/php.ini

RUN a2enmod rewrite

RUN composer install --no-dev --no-interaction --optimize-autoloader

RUN chown -R www-data:www-data storage bootstrap/cache

RUN php artisan storage:link

#RUN composer dump-autoload

EXPOSE 80
