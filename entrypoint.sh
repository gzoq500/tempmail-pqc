#!/bin/sh
set -e

# Configure msmtprc dynamically from environment variables
if [ -n "$SMTP_PASS" ]; then
    cat << EOF > /etc/msmtprc
defaults
auth on
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile /dev/null

account default
host ${SMTP_HOST:-smtp-relay.brevo.com}
port ${SMTP_PORT:-587}
from ${TEMPMAIL_DOMAIN:-routerssh.web.id}
user ${SMTP_USER:-b2d584001@smtp-brevo.com}
password ${SMTP_PASS}
EOF
    chmod 600 /etc/msmtprc
fi

exec "$@"
