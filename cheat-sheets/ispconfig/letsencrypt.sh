#!/bin/bash
URL="$1"
SITE_DIR="/var/www/${1}/ssl"

ln -sf /var/letsencrypt/live/${1}/cert.pem  ${SITE_DIR}/${1}.crt
ln -sf /var/letsencrypt/live/${1}/privkey.pem ${SITE_DIR}/${1}.key
ln -sf /var/letsencrypt/live/${1}/chain.pem ${SITE_DIR}/${1}.bundle
