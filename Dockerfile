FROM php:7.3-apache-stretch

ARG SSL_RELEASE
ARG BUILD_DATE
ARG VERSION

LABEL build_version="Docker image version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL description="LDAP Tool Box Self Service Password container image (from anagno)"
LABEL maintainer="Vasileios Anagnostopoulos <info@anagno.me>"

# entrypoint.sh dependencies
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bash \
        ; \
    rm -rf /var/lib/apt/lists/*;

# install the PHP extensions we need
# see https://github.com/ltb-project/self-service-password#prerequisite
RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libmcrypt-dev \
        libldap2-dev \
    ; \
    \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch"; \
    docker-php-ext-install \
        ldap \
        mbstring \
    ; \
    \
    # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN a2enmod headers && \
    a2enmod rewrite remoteip ;\
    {\
     echo RemoteIPHeader X-Real-IP ;\
     echo RemoteIPTrustedProxy 10.0.0.0/8 ;\
     echo RemoteIPTrustedProxy 172.16.0.0/12 ;\
     echo RemoteIPTrustedProxy 192.168.0.0/16 ;\
    } > /etc/apache2/conf-available/remoteip.conf;\
a2enconf remoteip

ADD config/apache.conf /etc/apache2/sites-enabled/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# installing the serf-service-password
RUN \
    if [ -z ${SSL_RELEASE} ]; then \
        SSL_RELEASE=$(curl -sX GET "https://api.github.com/repos/ltb-project/self-service-password/releases" \
        | awk '/tag_name/{print $4;exit}' FS='[""]'); \
    fi && \
    echo "SSL_RELEASE: " ${SSL_RELEASE} && \
    curl -o \
        /tmp/self-service-password.tar.gz -SL \
        https://github.com/ltb-project/self-service-password/archive/${SSL_RELEASE}.tar.gz && \
    tar xf \
        /tmp/self-service-password.tar.gz -C \
        /var/www/html --strip-components=1 && \
    rm -rf \
        /tmp/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# We are removing the configuration because we will create it in the entrypoint.sh
RUN rm -r /var/www/html/conf/config.inc.php

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]

# Copyright (c) 2019 Vasileios Athanasios Anagnostopoulos

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
