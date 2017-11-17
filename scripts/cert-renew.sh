#!/bin/bash
set -o nounset

WEB_ROOT="/opt/zimbra/jetty/webapps/zimbra/public/"
SCRIPTNAME=${0##*/}
ZIMBRA_LETSENCRYPT_DIR="/opt/zimbra/ssl/letsencrypt"
ZIMBRA_SSL_DIR="/opt/zimbra/ssl/letsencrypt"
CERTPATH=/etc/letsencrypt/live/`hostname -f`
DATE_FORMAT=`date +%Y-%m-%d`
CERTBOT_BIN="/usr/local/bin/certbot-auto"

install_certbot () {
    if [[ ! -f /usr/local/bin/certbot-auto ]]; then
    wget https://dl.eff.org/certbot-auto -P /usr/local/bin
    chmod a+x $CERTBOT_BIN
fi
}

stop_nginx () {
    echo "stop nginx"
    su - zimbra -c "zmproxyctl stop && zmmailboxdctl stop"
}

start_nginx () {
    echo "Starting nginx.."
    su - zimbra -c "zmproxyctl start && zmmailboxdctl start"
}

renew_ssl () {
    $CERTBOT_BIN renew  > /tmp/crt.txt
    cat /tmp/crt.txt | grep "No renewals were attempted"
    if [[ $? -eq "0" ]]; then
        echo "Cert not yet due for renewal"
        exit 0
    else

    # Create Letsencypt ssl dir if doesn't exist
    [[ -d $ZIMBRA_LETSENCRYPT_DIR ]] || mkdir -p $ZIMBRA_LETSENCRYPT_DIR

    # Copy Renewed letsencrypt certs
    rm -rf $ZIMBRA_LETSENCRYPT_DIR/*
    cp  $CERTPATH/*  $ZIMBRA_LETSENCRYPT_DIR
    ls -lh  /opt/zimbra/ssl/letsencrypt/

    # Build the proper Intermediate CA plus Root CA
cat $CERTPATH/chain.pem > $ZIMBRA_LETSENCRYPT_DIR/zimbra_chain.pem
cat >> $ZIMBRA_LETSENCRYPT_DIR/zimbra_chain.pem <<EOF
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----
EOF

chown -R zimbra:zimbra /opt/zimbra/ssl/letsencrypt/

# Verify your commercial certificate.

su - zimbra -c '/opt/zimbra/bin/zmcertmgr verifycrt comm /opt/zimbra/ssl/letsencrypt/privkey.pem /opt/zimbra/ssl/letsencrypt/cert.pem /opt/zimbra/ssl/letsencrypt/zimbra_chain.pem'

# 8.6
# /opt/zimbra/bin/zmcertmgr verifycrt comm /opt/zimbra/ssl/letsencrypt/privkey.pem /opt/zimbra/ssl/letsencrypt/cert.pem /opt/zimbra/ssl/letsencrypt/zimbra_chain.pem

# Backup stuff
cp -a /opt/zimbra/ssl/zimbra /opt/zimbra/ssl/zimbra.$DATE_FORMAT

# Copy the private key under Zimbra SSL path
cp $ZIMBRA_LETSENCRYPT_DIR/privkey.pem /opt/zimbra/ssl/zimbra/commercial/commercial.key

#  Final SSL deployment

su - zimbra -c '/opt/zimbra/bin/zmcertmgr deploycrt comm /opt/zimbra/ssl/letsencrypt/cert.pem /opt/zimbra/ssl/letsencrypt/zimbra_chain.pem'

# 8.6
# /opt/zimbra/bin/zmcertmgr deploycrt comm /opt/zimbra/ssl/letsencrypt/cert.pem /opt/zimbra/ssl/letsencrypt/zimbra_chain.pem


# If ssl renewal successful, renew cert

if [[ $? -eq "0" ]]; then
    su - zimbra -c "zmcontrol restart"
    if [[ $? -eq "0" ]]; then
        echo "" > /tmp/success
        echo "Letsencrypt ssl certificate for `hostname -f` successfully renewed by cron job." >> /tmp/success
        echo "" >> /tmp/success
        echo "Zimbra successfully restarted after renewal" >> /tmp/success
        mail -s "`hostname -f` Letsencrypt renewal" support-notify@angani.co < /tmp/success
    else
        echo "" > /tmp/failure
        echo "Letsencrypt ssl certificate for `hostname -f` renewal by cron job failed." >> /tmp/failure
        echo "" >> /tmp/failure
        echo "Try again manually.." >> /tmp/failure
        mail -s "`hostname -f` Letsencrypt renewal" support-notify@angani.co < /tmp/failure
    fi
fi
fi
}

# Main

install_certbot
renew_ssl

