FROM php:7.3-fpm-alpine3.9

ARG SSL_RELEASE

LABEL maintainer="Vasileios Anagnostopoulos <info@anagno.me>"
LABEL description="Docker repository for creating images for the LDAP Tool Box Self Service Password"

# entrypoint.sh dependencies
RUN set -ex; \
    \
    apk add --no-cache \
        bash \
        libldap

# install the PHP extensions we need
# see https://github.com/ltb-project/self-service-password#prerequisite
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        libmcrypt-dev \
        openldap-dev \
    ; \
    \
    docker-php-ext-configure ldap; \
    docker-php-ext-install \
        ldap \
        mbstring \
    ; \
    \
    apk del .build-deps

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# installing the serf-service-password
RUN \
    if [ -z ${SSL_RELEASE+x} ]; then \
        SSL_RELEASE=$(curl -sX GET "https://api.github.com/repos/ltb-project/self-service-password/releases" \
	    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
    fi && \
    curl -o \
        /tmp/self-service-password.tar.gz -SL \
        https://github.com/ltb-project/self-service-password/archive/${SSL_RELEASE}.tar.gz && \
    tar xf \
        /tmp/self-service-password.tar.gz -C \
        /var/www/html --strip-components=1 && \
    rm -rf \
        /tmp/*

COPY config.inc.php.template /var/www/html/conf/config.inc.php
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]

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