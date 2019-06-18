# docker-SelfServicePassword
Docker repository for creating images for the LDAP Tool Box Self Service Password



docker build -t anagno/ssl .
docker run -e LDAP_SERVER="test" -e LDAP_BINDDN="LDAP_BINDDN" -e LDAP_BINDPASS="LDAP_BINDPASS" -e LDAP_BASE_SEARCH="LDAP_BASE_SEARCH" anagno/ssl


## Available Configuration Parameters
| Parameter | Description |
|-----------|-------------|
| `DEBUG` | Set this to `true` to enable entrypoint debugging. Defaults to `false`. |
| `LDAP_SERVER: ` | Ldap server. **It is required.** |
| `LDAP_STARTTLS: ` | Enable TLS on Ldap bind. Defaults to `false`. |
| `LDAP_BINDDN: ` | Ldap bind dn. **It is required.** |
| `LDAP_BINDPASS: ` | Ldap bind password. **It is required.** |
| `LDAP_BASE: ` | Base where we can search for users. **It is required.** |
| `LDAP_LOGIN_ATTRIBUTE: ` | Ldap property used for user searching. Defaults to `uid` |
| `LDAP_FULLNAME_ATTRIBUTE: ` | Ldap property to get user fullname. Defaults to `cn` |
| `LDAP_FILTER: ` | Ldap property to set the filter. Defaults to `(&(objectClass=person)($ldap_login_attribute={login}))`. You will have to **escape the & character** by using \. E.g. `(\&(objectClass=person)($ldap_login_attribute={login}))` |
| `AD_MODE: ` | Specifies if LDAP server is Active Directory LDAP server. If your LDAP server is AD, set this to `true`. Defaults to `false`. |
| `AD_OPT_FORCE_UNLOCK: ` | Force account unlock when password is changed.  Default to `false`.|
| `AD_OPT_FORCE_PWD_CHANGE: ` | Force user change password at next login.  Defaults to `false`. |
| `AD_OPT_CHANGE_EXPIRED_PASSWORD: ` | Allow user with expired password to change password. Defaults to `false`. |
| `SAMBA_MODE: ` | Samba mode, if is `true` update sambaNTpassword and sambaPwdLastSet attributes too; if is `false` just update the password. Defaults to `false`. |
| `SHADOW_OPT_UPDATE_SHADOWLASTCHANGE: ` | If `true` update shadowLastChange.  Defaults to `false`. |
| `PASSWORD_HASH: ` |  Hash mechanism for password: `SSHA` `SHA` `SMD5` `MD5` `CRYPT` `clear` (the default) `auto` (will check the hash of current password)  **This option is not used with ad_mode = true** |
| `PASSWORD_MIN_LENGTH: ` | Minimal length. Defaults to `0` (unchecked). |
| `PASSWORD_MAX_LENGTH: ` | Maximal length. Defaults to `0` (unchecked). |
| `PASSWORD_MIN_LOWERCASE: ` | Minimal lower characters. Defaults to `0` (unchecked).  |
| `PASSWORD_MIN_UPPERCASE: ` | Minimal upper characters. Defaults to `0` (unchecked).  |
| `PASSWORD_MIN_DIGIT: ` | Minimal digit characters. Defaults to `0` (unchecked).  |
| `PASSWORD_MIN_SPECIAL: ` | Minimal special characters. Defaults to `0` (unchecked).  |
| `PASSWORD_NO_REUSE: ` | Dont reuse the same password as currently. Defaults to `false`. |
| `PASSWORD_SHOW_POLICY: ` | Show policy constraints message: `always` `never` `onerror`. Defaults to `never` |
| `PASSWORD_SHOW_POLICY_POSITION: ` | Position of password policy constraints message: `above` `below` - the form. Defaults to `above` |
| `WHO_CAN_CHANGE_PASSWORD: ` | Who changes the password?  Also applicable for question/answer save `user`: the user itself `manager`: the above binddn. Defaults to `user` |
| `QUESTIONS_ENABLED: ` | Use questions/answers?  `true` or `false`. Defaults to `false` |
| `LDAP_MAIL_ATTRIBUTE: ` | LDAP mail attribute. Defaults to `mail` |
| `MAIL_FROM: ` | Who the email should come from. Defaults to `admin@example.com` |
| `MAIL_FROM_NAME: ` | Name for `MAIL_FROM`. Defaults to `No Reply`|
| `NOTIFY_ON_CHANGE: ` | Notify users anytime their password is changed. Defaults to `false` |
| `SMTP_DEBUG: ` | SMTP debug mode (following https:////github.com/PHPMailer/PHPMailer instructions). Defaults to `0` |
| `SMTP_HOST: ` | SMTP host. Defaults to `localhost`. |
| `SMTP_AUTH: ` | Force smtp auth with `SMTP_USER` and `SMTP_PASS`. Defaults to `false` |
| `SMTP_USER: ` | SMTP user. No default. |
| `SMTP_PASS: ` | SMTP password. No default. |
| `SMTP_PORT: ` | SMTP port. Defaults to `587` |
| `SMTP_SECURE_TYPE: ` | SMTP secure type to use. `ssl` or `tls`. Defaults to `tls` |
| `USE_SMS: ` | Enable sms notify. (Disabled on this image). Defaults to `false` |
| `IS_BEHIND_PROXY: ` | Enable reset url parameter to accept reverse proxy. Defaults to `false`  |
| `DEBUG_MODE: ` | Debug mode. Defaults to `false`. |
| `SECRET_KEY: ` | Encryption, decryption keyphrase. Defaults to `secret`. |
| `USE_RECAPTCHA: ` | Use Google reCAPTCHA (http://www.google.com/recaptcha). Defaults to `false` |
| `RECAPTCHA_PUB_KEY: ` | Go on the site to get public key |
| `RECAPTCHA_PRIV_KEY: ` | Go on the site to get private key |
| `DEFAULT_ACTION: ` | Default action: `change` `sendtoken` `sendsms`. Defaults to `change` |