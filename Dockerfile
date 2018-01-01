# get hubic2swiftgate
# Replace filesystem locations for cache and config to /config
FROM alpine:3.5 AS builder
RUN apk add --no-cache git && \
  git clone https://github.com/oderwat/hubic2swiftgate /tmp/hubic2swiftgate && \
  sed -i "s#dirname(__FILE__).'/../cache'#'/config/cache'#" /tmp/hubic2swiftgate/www/simple.php && \
  sed -i "s#dirname(__FILE__).'/../config.php'#'/config/config.php'#" /tmp/hubic2swiftgate/www/simple.php

################################################################################

FROM php:7.0-apache
MAINTAINER Falk Reimann <falk.rei@gmail.com>

# Site Config
RUN ln -s /config/apache/001-hubic2swiftgate.conf /etc/apache2/sites-enabled/001-hubic2swiftgate.conf

# Modified hubic2swiftgate Code
RUN mkdir /var/www/hubic2swiftgate
COPY --from=builder /tmp/hubic2swiftgate/www /var/www/hubic2swiftgate/
RUN chown -R www-data:www-data /var/www/hubic2swiftgate

# Enable modules
RUN a2enmod rewrite && \
  a2enmod ssl

# ports and volumes
EXPOSE 443
VOLUME /config
