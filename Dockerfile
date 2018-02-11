# get hubic2swiftgate
# Replace filesystem locations for cache and config to /config
# get dumb-init
FROM alpine:3.5 AS builder
RUN apk add --no-cache git curl && \
  git clone https://github.com/oderwat/hubic2swiftgate /tmp/hubic2swiftgate && \
  sed -i "s#dirname(__FILE__).'/../cache'#'/config/cache'#" /tmp/hubic2swiftgate/www/simple.php && \
  sed -i "s#dirname(__FILE__).'/../config.php'#'/config/config.php'#" /tmp/hubic2swiftgate/www/simple.php && \
  curl -L -o /tmp/dumb-init.deb https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64.deb

################################################################################

FROM php:7.0-apache
MAINTAINER Falk Reimann <falk.rei@gmail.com>

# dump-init
COPY --from=builder /tmp/dumb-init.deb /tmp/dumb-init.deb
RUN dpkg -i /tmp/dumb-init.deb && \
  rm /tmp/dumb-init.deb

COPY setup_permissions /usr/local/bin/setup_permissions
RUN chmod +x /usr/local/bin/setup_permissions

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

ENTRYPOINT ["dumb-init", "--"]
CMD ["bash", "-c", "setup_permissions && exec apache2-foreground"]
