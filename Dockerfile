FROM php:7.4-fpm

# Valeur genre @composer pour le latest: https://github.com/mlocati/docker-php-extension-installer#installing-composer 
ARG COMPOSER='@composer'
# Valeur pour latest sinon voir: https://github.com/mlocati/docker-php-extension-installer#installing-specific-versions-of-an-extension
ARG ZIP='zip'
ARG INTL='intl'
ARG OPCACHE='opcache'
ARG APCU='apcu'
ARG REDIS='redis'
ARG PDO_PGSQL='pdo_pgsql'
ARG IMAGICK='imagick'
ARG XDEBUG=''

ENV PHP_SECURITY_CHECHER_VERSION=1.0.0

RUN apt-get update && apt-get install -y \
      wget \
      git \
      fish

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions ${ZIP} ${INTL} ${OPCACHE} ${APCU} ${REDIS} ${PDO_PGSQL} ${MYSQLI} ${PDO_MYSQL} ${IMAGICK} ${COMPOSER}

RUN [ ! -z "${XDEBUG}" ] && install-php-extensions ${XDEBUG} && \
    echo "xdebug.remote_enable=On\n\
xdebug.remote_connect_back=On\n\
xdebug.remote_host=${WWW_XDEBUG_HOST}\n\
xdebug.remote_port=${WWW_XDEBUG_PORT}\n\
xdebug.idekey=${WWW_XDEBUG_IDE}\n\
xdebug.profiler_enable_trigger=1\n\
xdebug.profiler_output_dir = /var/www/xdebug_www_profiler_output" > /usr/local/etc/php/conf.d/xdebug.ini || echo "[INFO] XDEBUG not installed"

# Symfony tool
RUN wget https://get.symfony.com/cli/installer -O - | bash && \
  mv /root/.symfony/bin/symfony /usr/local/bin/symfony

# Security checker tool
RUN curl -L https://github.com/fabpot/local-php-security-checker/releases/download/v${PHP_SECURITY_CHECHER_VERSION}/local-php-security-checker_${PHP_SECURITY_CHECHER_VERSION}_linux_$(dpkg --print-architecture) --output /usr/local/bin/local-php-security-checker && \
  chmod +x /usr/local/bin/local-php-security-checker

# Pour la récupération des durées
RUN apt-get update && apt-get install -y ffmpeg

WORKDIR /var/www

EXPOSE 9000
