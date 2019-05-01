#!/bin/bash

usage() {
    cat <<EOM
    Usage:
    $(basename $0) ca_passphrase domain1 domain2 ...
    domain certs files are created in ~/.ca
EOM
    exit 0
}

create_ca_dir() {
    if [ ! -d "$CADIR" ]; then
        mkdir -p $CADIR
    fi
}

generate_ca_crt() {
    if [ ! -f "$CACERT" ]; then
        echo $CAPASS
        # generate ca private key
        openssl genrsa -des3 -out "$CAKEY" -passout pass:$CAPASS 4096

        # generate root CA Cert
        openssl req -x509 -new -nodes \
            -subj "/C=IN/ST=KA/O=MyCA/CN=ca.local" \
            -key "$CAKEY" -sha256 -days 1024 \
            -out "$CACERT" \
            -passin pass:$CAPASS
    fi
}

generate_web_cert() {
    local DOMAIN=$1
    local KEY=$CADIR/$DOMAIN.key
    local CSR=$CADIR/$DOMAIN.csr
    local CERT=$CADIR/$DOMAIN.crt

    # generate private key
    openssl genrsa -out "$KEY" 2048

    # generate csr
    openssl req -new -sha256 \
        -key "$KEY" \
        -subj "/C=IN/ST=KA/O=Myself/CN=$DOMAIN" \
        -reqexts SAN \
        -config <(cat /etc/ssl/openssl.cnf \
            <(printf "\n[SAN]\nsubjectAltName=DNS:$DOMAIN,DNS:*.$DOMAIN")) \
        -out "$CSR"

    # sign the csr
    openssl x509 -req \
        -extfile <(printf "subjectAltName=DNS:$DOMAIN,DNS:*.$DOMAIN") \
        -days 365 -in "$CSR" \
        -sha256 \
        -CA "$CACERT" -CAkey "$CAKEY" -CAcreateserial \
        -out "$CERT" \
        -passin pass:$CAPASS
}

[ -z $1 ] && { usage; }

CAPASS=$1; shift
CADIR=$HOME/.ca
CAKEY=$CADIR/ca.local.key
CACERT=$CADIR/ca.local.crt

create_ca_dir
generate_ca_crt

for domain in "$@"; do
    generate_web_cert "$domain"
done
