#!/bin/bash -e
set -o pipefail

# https://github.com/docker-library/postgres/blob/cf9b6cdd64f8a81b1abf9e487886f47e4971abe2/11/docker-entrypoint.sh
# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

CONFIG_PATH=/var/www/html/conf/config.inc.php
touch ${CONFIG_PATH}

file_env 'LDAP_SERVER'
if [[ -z "${LDAP_SERVER}" ]]; then
    echo "[ERROR] Mandatory variable LDAP_SERVER not defined."
    exit 1
fi
sed -i s/LDAP_URL_PLACEHOLDER/"${LDAP_SERVER}"/ $CONFIG_PATH

file_env 'LDAP_STARTTLS' 'false'
sed -i s/LDAP_STARTTLS_PLACEHOLDER/"${LDAP_STARTTLS}"/ $CONFIG_PATH

file_env 'LDAP_BINDDN'
if [[ -z "${LDAP_BINDDN}" ]]; then
    echo "[ERROR] Mandatory variable LDAP_BINDDN not defined."
    exit 1
fi
sed -i s/LDAP_BINDDN_PLACEHOLDER/"${LDAP_BINDDN}"/ $CONFIG_PATH

file_env 'LDAP_BINDPASS'
if [[ -z "${LDAP_BINDPASS}" ]]; then
    echo "[ERROR] Mandatory variable LDAP_BINDPASS not defined."
    exit 1
fi
sed -i s/LDAP_BINDPASS_PLACEHOLDER/"${LDAP_BINDPASS}"/ $CONFIG_PATH

file_env 'LDAP_BASE_SEARCH'
if [[ -z "${LDAP_BASE_SEARCH}" ]]; then
    echo "[ERROR] Mandatory variable LDAP_BASE_SEARCH not defined."
    exit 1
fi
sed -i s/LDAP_BASE_PLACEHOLDER/"${LDAP_BASE_SEARCH}"/ $CONFIG_PATH

file_env 'LDAP_LOGIN_ATTRIBUTE' 'uid'
sed -i s/LDAP_LOGIN_ATTRIBUTE_PLACEHOLDER/"${LDAP_LOGIN_ATTRIBUTE}"/ $CONFIG_PATH

file_env 'LDAP_FULLNAME_ATTRIBUTE' 'cn'
sed -i s/LDAP_FULLNAME_ATTRIBUTE_PLACEHOLDER/"${LDAP_FULLNAME_ATTRIBUTE}"/ $CONFIG_PATH

file_env 'LDAP_FILTER' '(\&(objectClass=person)($ldap_login_attribute={login}))'
sed -i s/LDAP_FILTER_PLACEHOLDER/"${LDAP_FILTER}"/ $CONFIG_PATH

file_env 'AD_MODE' 'false'
sed -i s/AD_MODE_PLACEHOLDER/"${AD_MODE}"/ $CONFIG_PATH

file_env 'AD_OPT_FORCE_UNLOCK' 'false'
sed -i s/AD_OPT_FORCE_UNLOCK_PLACEHOLDER/"${AD_OPT_FORCE_UNLOCK}"/ $CONFIG_PATH

file_env 'AD_OPT_FORCE_PWD_CHANGE' 'false'
sed -i s/AD_OPT_FORCE_PWD_CHANGE_PLACEHOLDER/"${AD_OPT_FORCE_PWD_CHANGE}"/ $CONFIG_PATH

file_env 'AD_OPT_CHANGE_EXPIRED_PASSWORD' 'false'
sed -i s/AD_OPT_CHANGE_EXPIRED_PASSWORD_PLACEHOLDER/"${AD_OPT_CHANGE_EXPIRED_PASSWORD}"/ $CONFIG_PATH

file_env 'SAMBA_MODE' 'false'
sed -i s/SAMBA_MODE_PLACEHOLDER/"${SAMBA_MODE}"/ $CONFIG_PATH

file_env 'SHADOW_OPT_UPDATE_SHADOWLASTCHANGE' 'false'
sed -i s/SHADOW_OPT_UPDATE_SHADOWLASTCHANGE_PLACEHOLDER/"${SHADOW_OPT_UPDATE_SHADOWLASTCHANGE}"/ $CONFIG_PATH

file_env 'PASSWORD_HASH' 'auto'
sed -i s/PASSWORD_HASH_PLACEHOLDER/"${PASSWORD_HASH}"/ $CONFIG_PATH

file_env 'PASSWORD_MIN_LENGTH' '0'
sed -i s/PASSWORD_MIN_LENGTH_PLACEHOLDER/"${PASSWORD_MIN_LENGTH}"/ $CONFIG_PATH

file_env 'PASSWORD_MAX_LENGTH' '0'
sed -i s/PASSWORD_MAX_LENGTH_PLACEHOLDER/"${PASSWORD_MAX_LENGTH}"/ $CONFIG_PATH

file_env 'PASSWORD_MIN_LOWERCASE' '0'
sed -i s/PASSWORD_MIN_LOWERCASE_PLACEHOLDER/"${PASSWORD_MIN_LOWERCASE}"/ $CONFIG_PATH

file_env 'PASSWORD_MIN_UPPERCASE' '0'
sed -i s/PASSWORD_MIN_UPPERCASE_PLACEHOLODER/"${PASSWORD_MIN_UPPERCASE}"/ $CONFIG_PATH

file_env 'PASSWORD_MIN_DIGIT' '0'
sed -i s/PASSWORD_MIN_DIGIT_PLACEHOLDER/"${PASSWORD_MIN_DIGIT}"/ $CONFIG_PATH

file_env 'PASSWORD_MIN_SPECIAL' '0'
sed -i s/PASSWORD_MIN_SPECIAL_PLACEHOLDER/"${PASSWORD_MIN_SPECIAL}"/ $CONFIG_PATH

file_env 'PASSWORD_NO_REUSE' 'false'
sed -i s/PASSWORD_NO_REUSE_PLACEHOLDER/"${PASSWORD_NO_REUSE}"/ $CONFIG_PATH

file_env 'PASSWORD_SHOW_POLICY' 'never'
sed -i s/PASSWORD_SHOW_POLICY_PLACEHOLDER/"${PASSWORD_SHOW_POLICY}"/ $CONFIG_PATH

file_env 'PASSWORD_SHOW_POLICY_POSITION' 'above'
sed -i s/PASSWORD_SHOW_POLICY_POSITION_PLACEHOLDER/"${PASSWORD_SHOW_POLICY_POSITION}"/ $CONFIG_PATH

file_env 'WHO_CAN_CHANGE_PASSWORD' 'user'
sed -i s/WHO_CAN_CHANGE_PASSWORD_PLACEHOLDER/"${WHO_CAN_CHANGE_PASSWORD}"/ $CONFIG_PATH

file_env 'QUESTIONS_ENABLED' 'false'
sed -i s/QUESTIONS_ENABLED_PLACEHOLDER/"${QUESTIONS_ENABLED}"/ $CONFIG_PATH

file_env 'LDAP_MAIL_ATTRIBUTE' 'mail'
sed -i s/LDAP_MAIL_ATTRIBUTE_PLACEHOLDER/"${LDAP_MAIL_ATTRIBUTE}"/ $CONFIG_PATH

file_env 'MAIL_FROM' 'admin@example.com'
sed -i s/MAIL_FROM_PLACEHOLDER/"${MAIL_FROM}"/ $CONFIG_PATH

file_env 'MAIL_FROM_NAME' 'No Reply'
sed -i s/MAIL_FROM_NAME_PLACEHOLDER/"${MAIL_FROM_NAME}"/ $CONFIG_PATH

file_env 'NOTIFY_ON_CHANGE' 'false'
sed -i s/NOTIFY_ON_CHANGE_PLACEHOLDER/"${NOTIFY_ON_CHANGE}"/ $CONFIG_PATH

file_env 'SMTP_DEBUG' '0'
sed -i s/SMTP_DEBUG_PLACEHOLDER/"${SMTP_DEBUG}"/ $CONFIG_PATH

file_env 'SMTP_HOST' 'localhost'
sed -i s/SMTP_HOST_PLACEHOLDER/"${SMTP_HOST}"/ $CONFIG_PATH

file_env 'SMTP_AUTH' 'false'
sed -i s/SMTP_AUTH_PLACEHOLDER/"${SMTP_AUTH}"/ $CONFIG_PATH

file_env 'SMTP_USER'
sed -i s/SMTP_USER_PLACEHOLDER/"${SMTP_USER}"/ $CONFIG_PATH

file_env 'SMTP_PASS'
sed -i s/SMTP_PASS_PLACEHOLDER/"${SMTP_PASS}"/ $CONFIG_PATH

file_env 'SMTP_PORT' '587'
sed -i s/SMTP_PORT_PLACEHOLDER/"${SMTP_PORT}"/ $CONFIG_PATH

file_env 'SMTP_SECURE_TYPE' 'tls'
sed -i s/SMTP_SECURE_TYPE_PLACEHOLDER/"${SMTP_SECURE_TYPE}"/ $CONFIG_PATH

file_env 'USE_SMS' 'false'
sed -i s/USE_SMS_PLACEHOLDER/"${USE_SMS}"/ $CONFIG_PATH

file_env 'SMS_MAIL_TO' '{sms_attribute}@service.provider.com'
sed -i s/SMS_MAIL_TO_PLACEHOLDER/"${SMS_MAIL_TO}"/ $CONFIG_PATH

file_env 'IS_BEHIND_PROXY' 'false'
if [ "${IS_BEHIND_PROXY}"  = true ]; then
	echo "# Reset URL (if behind a reverse proxy)" >> $CONFIG_PATH
	echo "\$reset_url = \$_SERVER['HTTP_X_FORWARDED_PROTO'] . \"://\" . \$_SERVER['HTTP_X_FORWARDED_HOST'] . \$_SERVER['SCRIPT_NAME'];" >> $CONFIG_PATH
fi

file_env 'SECRET_KEY' 'secret'
sed -i s/SECRET_KEY_PLACEHOLDER/"${SECRET_KEY}"/ $CONFIG_PATH

file_env 'USE_RECAPTCHA' 'false'
sed -i s/USE_RECAPTCHA_PLACEHOLDER/"${USE_RECAPTCHA}"/ $CONFIG_PATH

file_env 'RECAPTCHA_PUB_KEY'
sed -i s/RECAPTCHA_PUB_KEY_PLACEHOLDER/"${RECAPTCHA_PUB_KEY}"/ $CONFIG_PATH

file_env 'RECAPTCHA_PRIV_KEY'
sed -i s/RECAPTCHA_PRIV_KEY_PLACEHOLDER/"${RECAPTCHA_PRIV_KEY}"/ $CONFIG_PATH

file_env 'DEFAULT_ACTION' 'change'
sed -i s/DEFAULT_ACTION_PLACEHOLDER/"${DEFAULT_ACTION}"/ $CONFIG_PATH

file_env 'DEBUG' 'false'
sed -i s/DEBUG_PLACEHOLDER/"${DEBUG}"/ $CONFIG_PATH

if [ "${DEBUG}"  = true ]; then
    echo "[INFO] Printing out the /var/www/html/conf/config.inc.php:"
    cat $CONFIG_PATH
fi

exec "$@"

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
