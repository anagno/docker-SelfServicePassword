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

echo "<?php" >> $CONFIG_PATH


file_env 'DEBUG' 'false'
echo "\$debug = "${DEBUG}";" >> $CONFIG_PATH

file_env 'LDAP_SERVER'
if [[ -z "${LDAP_SERVER}" ]]; then
    echo "[ERROR] Mandatory variable LDAP_SERVER not defined."
    exit 1
fi
echo "\$ldap_url = \"${LDAP_SERVER}\";" >> $CONFIG_PATH


file_env 'LDAP_STARTTLS' 'false'
echo "\$ldap_starttls = "${LDAP_STARTTLS}";" >> $CONFIG_PATH
 
file_env 'LDAP_BINDDN'
if [[ -z "${LDAP_BINDDN}" ]]; then
    echo "[ERROR] Mandatory variable LDAP_BINDDN not defined."
    exit 1
fi
echo "\$ldap_binddn = \"${LDAP_BINDDN}\";" >> $CONFIG_PATH

file_env 'LDAP_BINDPASS'
if [[ -z "${LDAP_BINDPASS}" ]]; then
    echo "[ERROR] Mandatory variable LDAP_BINDPASS not defined."
    exit 1
fi
echo "\$ldap_bindpw = \"${LDAP_BINDPASS}\";" >> $CONFIG_PATH

file_env 'LDAP_BASE_SEARCH'
if [[ -z "${LDAP_BASE_SEARCH}" ]]; then
    echo "[ERROR] Mandatory variable LDAP_BASE_SEARCH not defined."
    exit 1
fi
echo "\$ldap_base = \"${LDAP_BASE_SEARCH}\";" >> $CONFIG_PATH

file_env 'LDAP_LOGIN_ATTRIBUTE' 'uid'
echo "\$ldap_login_attribute = \"${LDAP_LOGIN_ATTRIBUTE}\";" >> $CONFIG_PATH

file_env 'LDAP_FULLNAME_ATTRIBUTE' 'cn'
echo "\$ldap_fullname_attribute = \"${LDAP_FULLNAME_ATTRIBUTE}\";" >> $CONFIG_PATH

file_env 'LDAP_FILTER' '(&(objectClass=person)($ldap_login_attribute={login}))'
echo "\$ldap_filter = \"${LDAP_FILTER}\";" >> $CONFIG_PATH

file_env 'AD_MODE' 'false'
echo "\$ad_mode = "${AD_MODE}";" >> $CONFIG_PATH

file_env 'AD_OPT_FORCE_UNLOCK' 'false'
echo "\$ad_options['force_unlock'] = "${AD_OPT_FORCE_UNLOCK}";" >> $CONFIG_PATH

file_env 'AD_OPT_FORCE_PWD_CHANGE' 'false'
echo "\$ad_options['force_pwd_change'] = "${AD_OPT_FORCE_PWD_CHANGE}";" >> $CONFIG_PATH

file_env 'AD_OPT_CHANGE_EXPIRED_PASSWORD' 'false'
echo "\$ad_options['change_expired_password'] = "${AD_OPT_CHANGE_EXPIRED_PASSWORD}";" >> $CONFIG_PATH

file_env 'SAMBA_MODE' 'false'
echo "\$samba_mode = "${SAMBA_MODE}";" >> $CONFIG_PATH

file_env 'SHADOW_OPT_UPDATE_SHADOWLASTCHANGE' 'false' >> $CONFIG_PATH
echo "\$shadow_options['update_shadowLastChange']" = ${SHADOW_OPT_UPDATE_SHADOWLASTCHANGE}";" >> $CONFIG_PATH
echo "\$shadow_options['update_shadowExpire'] = false;" >> $CONFIG_PATH
echo "\$shadow_options['shadow_expire_days'] = -1;" >> $CONFIG_PATH

file_env 'PASSWORD_HASH' 'auto'
echo "\$hash = \"${PASSWORD_HASH}\";" >> $CONFIG_PATH

echo "\$hash_options['crypt_salt_prefix'] = \"\$6\$\";" >> $CONFIG_PATH
echo "\$hash_options['crypt_salt_length'] = \"6\";" >> $CONFIG_PATH

file_env 'PASSWORD_MIN_LENGTH' '0'
echo "\$pwd_min_length = "${PASSWORD_MIN_LENGTH}";" >> $CONFIG_PATH

file_env 'PASSWORD_MAX_LENGTH' '0'
echo "\$pwd_max_length = "${PASSWORD_MAX_LENGTH}";" >> $CONFIG_PATH

file_env 'PASSWORD_MIN_LOWERCASE' '0'
echo "\$pwd_min_lower = "${PASSWORD_MIN_LOWERCASE}";" >> $CONFIG_PATH

file_env 'PASSWORD_MIN_UPPERCASE' '0'
echo "\$pwd_min_upper = "${PASSWORD_MIN_UPPERCASE}";" >> $CONFIG_PATH

file_env 'PASSWORD_MIN_DIGIT' '0'
echo "\$pwd_min_digit = "${PASSWORD_MIN_DIGIT}";" >> $CONFIG_PATH

file_env 'PASSWORD_MIN_SPECIAL' '0'
echo "\$pwd_min_special = "${PASSWORD_MIN_DIGIT}";" >> $CONFIG_PATH

echo "\$pwd_special_chars = \"^a-zA-Z0-9\";" >> $CONFIG_PATH

file_env 'PASSWORD_NO_REUSE' 'false'
echo "\$pwd_no_reuse = "${PASSWORD_NO_REUSE}";" >> $CONFIG_PATH

echo "\$pwd_diff_login = true;" >> $CONFIG_PATH
echo "\$pwd_complexity = 0;" >> $CONFIG_PATH

file_env 'USE_PWNED' 'false'
echo "\$use_pwnedpasswords = "${USE_PWNED}";" >> $CONFIG_PATH

file_env 'PASSWORD_SHOW_POLICY' 'never'
echo "\$pwd_show_policy = \"${PASSWORD_SHOW_POLICY}\";" >> $CONFIG_PATH

file_env 'PASSWORD_SHOW_POLICY_POSITION' 'above'
echo "\$pwd_show_policy_pos = \"${PASSWORD_SHOW_POLICY_POSITION}\";" >> $CONFIG_PATH

echo "\$pwd_no_special_at_ends = false;" >> $CONFIG_PATH

file_env 'WHO_CAN_CHANGE_PASSWORD' 'user'
echo "\$who_change_password = \"${WHO_CAN_CHANGE_PASSWORD}\";" >> $CONFIG_PATH

echo "\$use_change = true;" >> $CONFIG_PATH
echo "\$change_sshkey = false;" >> $CONFIG_PATH
echo "\$change_sshkey_attribute = \"sshPublicKey\";" >> $CONFIG_PATH
echo "\$who_change_sshkey = \"user\";" >> $CONFIG_PATH
echo "\$notify_on_sshkey_change = false;" >> $CONFIG_PATH

file_env 'QUESTIONS_ENABLED' 'false'
echo "\$use_questions = "${QUESTIONS_ENABLED}";" >> $CONFIG_PATH

echo "\$answer_objectClass = \"extensibleObject\";" >> $CONFIG_PATH
echo "\$answer_attribute = \"info\";" >> $CONFIG_PATH
echo "\$crypt_answers = true;" >> $CONFIG_PATH

echo "\$use_tokens = true;" >> $CONFIG_PATH
echo "\$token_lifetime = \"3600\";" >> $CONFIG_PATH
echo "\$crypt_tokens = true;" >> $CONFIG_PATH

file_env 'LDAP_MAIL_ATTRIBUTE' 'mail'
echo "\$mail_attribute = \"${LDAP_MAIL_ATTRIBUTE}\";" >> $CONFIG_PATH

echo "\$mail_address_use_ldap = false;" >> $CONFIG_PATH

file_env 'MAIL_FROM' 'admin@example.com'
echo "\$mail_from = \"${MAIL_FROM}\";" >> $CONFIG_PATH

file_env 'MAIL_FROM_NAME' 'No Reply'
echo "\$mail_from_name = \"${MAIL_FROM_NAME}\";" >> $CONFIG_PATH

echo "\$mail_signature = \"\";" >> $CONFIG_PATH

file_env 'NOTIFY_ON_CHANGE' 'false'
echo "\$notify_on_change = " ${NOTIFY_ON_CHANGE} ";" >> $CONFIG_PATH

echo "\$mail_sendmailpath = '/usr/sbin/sendmail';" >> $CONFIG_PATH
echo "\$mail_protocol = 'smtp';" >> $CONFIG_PATH

file_env 'SMTP_DEBUG' '0'
echo "\$mail_smtp_debug = " ${SMTP_DEBUG} ";" >> $CONFIG_PATH

echo "\$mail_debug_format = 'error_log';" >> $CONFIG_PATH

file_env 'SMTP_HOST' 'localhost'
echo "\$mail_smtp_host = '${SMTP_HOST}';" >> $CONFIG_PATH

file_env 'SMTP_AUTH' 'false'
echo "\$mail_smtp_auth = " ${SMTP_AUTH} ";" >> $CONFIG_PATH

file_env 'SMTP_USER'
echo "\$mail_smtp_user = '${SMTP_USER}';" >> $CONFIG_PATH

file_env 'SMTP_PASS'
echo "\$mail_smtp_pass = '${SMTP_PASS}';" >> $CONFIG_PATH

file_env 'SMTP_PORT' '587'
echo "\$mail_smtp_port = " ${SMTP_PORT} ";" >> $CONFIG_PATH

echo "\$mail_smtp_timeout = 30;" >> $CONFIG_PATH
echo "\$mail_smtp_keepalive = false;" >> $CONFIG_PATH

file_env 'SMTP_SECURE_TYPE' 'tls'
echo "\$mail_smtp_secure = '${SMTP_SECURE_TYPE}';" >> $CONFIG_PATH

echo "\$mail_smtp_autotls = true;" >> $CONFIG_PATH
echo "\$mail_contenttype = 'text/plain';" >> $CONFIG_PATH
echo "\$mail_wordwrap = 0;" >> $CONFIG_PATH
echo "\$mail_charset = 'utf-8';" >> $CONFIG_PATH
echo "\$mail_priority = 3;" >> $CONFIG_PATH
echo "\$mail_newline = PHP_EOL;" >> $CONFIG_PATH


file_env 'USE_SMS' 'false'
echo "\$use_sms = " ${USE_SMS} ";" >> $CONFIG_PATH

echo "\$sms_method = \"mail\";" >> $CONFIG_PATH
echo "\$sms_api_lib = \"lib/smsapi.inc.php\";" >> $CONFIG_PATH
echo "\$sms_attribute = \"mobile\";" >> $CONFIG_PATH
echo "\$sms_partially_hide_number = true;" >> $CONFIG_PATH

file_env 'SMS_MAIL_TO' '{sms_attribute}@service.provider.com'
echo "\$smsmailto = \"${SMS_MAIL_TO}\";" >> $CONFIG_PATH

echo "\$smsmail_subject = \"Provider code\";" >> $CONFIG_PATH
echo "\$sms_message = \"{smsresetmessage} {smstoken}\";" >> $CONFIG_PATH
echo "\$sms_sanitize_number = false;" >> $CONFIG_PATH
echo "\$sms_truncate_number = false;" >> $CONFIG_PATH
echo "\$sms_truncate_number_length = 10;" >> $CONFIG_PATH
echo "\$sms_token_length = 6;" >> $CONFIG_PATH
echo "\$max_attempts = 3;" >> $CONFIG_PATH

file_env 'IS_BEHIND_PROXY' 'false'
if [ "${IS_BEHIND_PROXY}"  = true ]; then
	echo "# Reset URL (if behind a reverse proxy)" >> $CONFIG_PATH
	echo "\$reset_url = \$_SERVER['HTTP_X_FORWARDED_PROTO'] . \"://\" . \$_SERVER['HTTP_X_FORWARDED_HOST'] . \$_SERVER['SCRIPT_NAME'];" >> $CONFIG_PATH
fi

file_env 'SECRET_KEY' 'secret'
echo "\$keyphrase = \"${SECRET_KEY}\";" >> $CONFIG_PATH

echo "\$show_help = true;" >> $CONFIG_PATH
echo "\$lang = \"en\";" >> $CONFIG_PATH
echo "\$allowed_lang = array();" >> $CONFIG_PATH
echo "\$show_menu = true;" >> $CONFIG_PATH
echo "\$logo = \"images/ltb-logo.png\";" >> $CONFIG_PATH
echo "\$background_image = \"images/unsplash-space.jpeg\";" >> $CONFIG_PATH
echo "\$login_forbidden_chars = \"*()&|\";" >> $CONFIG_PATH

file_env 'USE_RECAPTCHA' 'false'
echo "\$use_recaptcha = " ${USE_RECAPTCHA} ";" >> $CONFIG_PATH

file_env 'RECAPTCHA_PUB_KEY'
echo "\$recaptcha_publickey = \"${RECAPTCHA_PUB_KEY}\";" >> $CONFIG_PATH

file_env 'RECAPTCHA_PRIV_KEY'
echo "\$recaptcha_privatekey = \"${RECAPTCHA_PRIV_KEY}\";" >> $CONFIG_PATH

echo "\$recaptcha_theme = \"light\";" >> $CONFIG_PATH
echo "\$recaptcha_type = \"image\";" >> $CONFIG_PATH
echo "\$recaptcha_size = \"normal\";" >> $CONFIG_PATH
echo "\$recaptcha_request_method = null;" >> $CONFIG_PATH


file_env 'DEFAULT_ACTION' 'change'
echo "\$default_action = \"${DEFAULT_ACTION}\";" >> $CONFIG_PATH

echo "?>" >> $CONFIG_PATH

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
