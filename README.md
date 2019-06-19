# docker-SelfServicePassword

This is a simple container that is packaging the 
[LDAP Tool Box Self Service Password](https://ltb-project.org/documentation/self-service-password)

# How to use this image
This is image is designed to be used in micro-service environment. It does not provided an LDAP server,
which you will have to set up first. It is based on the [php-apache-stretch](https://hub.docker.com/_/php) 
image. It is designed to be a simple as possible and extensible. It does not need any persistent data
and can be restarted anytime. 


To start the container type:

```
docker run -e LDAP_SERVER="ldap://openldap:389" -e LDAP_BINDDN="cn=admin,dc=test,dc=com" -e LDAP_BINDPASS="StrongPassword" -e LDAP_BASE_SEARCH="dc=test,dc=com" -e DEBUG="true" anagno/self_service_password
```

It is compatible with docker-compose v3 and can be run on a docker swarm cluster. 
An example that uses the traefik proxy v.2 follows:

```
services:
  pwd:
    image: anagno/self_service_password
    environment:
      LDAP_SERVER: "ldap://openldap:389"
      LDAP_BINDDN: "cn=manager,dc=test,dc=com"
      LDAP_BINDPASS_FILE: /run/secrets/admin_pw
      LDAP_BASE_SEARCH: "dc=test,dc=com"
      PASSWORD_HASH: "SHA"
      SECRET_KEY_FILE: /run/secrets/pwd_crypt_tokens
      SMTP_HOST: "mail.test.net"
      SMTP_AUTH: "true"
      SMTP_USER: "no-reply@test.me"
      SMTP_PASS_FILE: /run/secrets/no_reply_mail_pw
      SMTP_PORT: 587
      SMTP_SECURE_TYPE: "tls"
      MAIL_FROM: "no-reply@test.me"
      IS_BEHIND_PROXY: "true"
    secrets:
      - admin_pw
      - no_reply_mail_pw
      - pwd_crypt_tokens
    networks:
      - proxy_public
      - authentication_internal
    deploy:
      mode: replicated
      replicas: 1
      labels:
        - traefik.enable=true
        - traefik.docker.network=proxy_public
        - traefik.HTTP.Routers.http-pwd.EntryPoints=http
        - traefik.HTTP.Routers.http-pwd.Rule=Host(`pwd.test.com`) 
        - traefik.HTTP.Routers.http-pwd.Middlewares=directory-redirect
        - traefik.HTTP.Middlewares.pwd-redirect.RedirectScheme.Scheme=https
        - traefik.HTTP.Middlewares.pwd-redirect.RedirectScheme.Permanent=true

        - traefik.HTTP.Routers.https-pwd.EntryPoints=https
        - traefik.HTTP.Routers.https-pwd.TLS=true
        - traefik.HTTP.Routers.https-pwd.Rule=Host(`pwd.test.com`) 

        - traefik.HTTP.Services.pwd.LoadBalancer.PassHostHeader=true
        - traefik.HTTP.Services.pwd.LoadBalancer.server.Port=80

secrets:
  admin_pw:
    external: true
  no_reply_mail_pw:
    external: true
  pwd_crypt_tokens:
    external: true

networks:
  proxy_public:
    external: true
  authentication_internal:
    external: true

```

# Configuration via environment variables

The available configuration variables are:

| Parameter | Description |
|-----------|-------------|
| `DEBUG` | Set this to `true` to enable entrypoint debugging. Defaults to `false`. |
| `LDAP_SERVER: ` | Ldap server. **It is required.** |
| `LDAP_STARTTLS: ` | Enable TLS on Ldap bind. Defaults to `false`. |
| `LDAP_BINDDN: ` | Ldap bind dn. **It is required.** |
| `LDAP_BINDPASS: ` | Ldap bind password. **It is required.** |
| `LDAP_BASE_SEARCH: ` | Base where we can search for users. **It is required.** |
| `LDAP_LOGIN_ATTRIBUTE: ` | Ldap property used for user searching. Defaults to `uid` |
| `LDAP_FULLNAME_ATTRIBUTE: ` | Ldap property to get user fullname. Defaults to `cn` |
| `LDAP_FILTER: ` | Ldap property to set the filter. Defaults to `(&(objectClass=person)($ldap_login_attribute={login}))`.
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
| `USE_PWNED: ` | Use the pwned service. Defaults to `false`. |
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


Most of the parameters are derived from the [LDAP Tool Box Self Service Password](https://ltb-project.org/documentation/self-service-password).
For more details on what they do, just look on the documentation of the project.

As an alternative to passing sensitive information via environmental variables, _FILE may be appended to the listed variables,
causing the entrypoint.sh script to load the values for those values from files presented in the container. This is particular
usefull for loading passwords using the [Docker secrets](https://docs.docker.com/engine/swarm/secrets/) mechanism.


# Building the image 

Just type:

```
docker build -t anagno/ssl .
```
and you are ready.


# Questions / Issues

If you got any questions or problems using the image, please visit the 
[Github Repository](https://github.com/anagno/docker-SelfServicePassword) of the 
projectand write an issue. I will try to answer them, but no promises :) 