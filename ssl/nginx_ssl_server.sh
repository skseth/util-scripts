#!/bin/bash

usage() {
    cat <<EOM
    Usage:
    $(basename $0) domainname url
    e.g. $(basename $0) kibana.host.local http://127.0.0.1:5601
EOM
    exit 0
}

[ -z $2 ] && { usage; }

DOMAIN=$1
URL=$2

CERTDIR=$HOME/.ca
CONFDIR=/usr/local/etc/nginx/servers
CONFFILE=$CONFDIR/$DOMAIN.conf


# adapted from : https://gist.github.com/shijij/54c9b21f26c08a15a70c182f03cb15b4
cat << EOF > $CONFFILE
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate           $CERTDIR/$DOMAIN.crt;
    ssl_certificate_key       $CERTDIR/$DOMAIN.key;
    ssl_ecdh_curve prime256v1;

    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE+aECDSA+CHACHA20:ECDHE+aRSA+CHACHA20:ECDHE+aECDSA+AESGCM:ECDHE+aRSA+AESGCM:ECDHE+aECDSA+AES256+SHA384:ECDHE+aRSA+AES256+SHA384:ECDHE+aECDSA+AES256+SHA:ECDHE+aRSA+AES256+SHA';


    location / {
      proxy_set_header        Host \$host;
      proxy_set_header        X-Real-IP \$remote_addr;
      proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto \$scheme;

      # Fix the “It appears that your reverse proxy set up is broken" error.

      proxy_pass          $URL;
      proxy_read_timeout  60;
      proxy_ssl_name \$host;
      proxy_ssl_server_name on;
      proxy_ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
      proxy_ssl_session_reuse off;
    }

}
EOF