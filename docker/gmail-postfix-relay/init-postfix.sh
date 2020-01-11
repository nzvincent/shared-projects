#!/bin/bash

set -e

# SMTP relay host
[[ -e $RELAYHOST ]] && POSTFIX_RELAYHOST=$RELAYHOST || POSTFIX_RELAYHOST="smtp.gmail.com"
[[ -e $RELAYHOST_PORT ]] && POSTFIX_RELAYHOST_PORT=$RELAYHOST_PORT || POSTFIX_RELAYHOST_PORT="587"

# SMTP login
[[ -e $RELAYHOST_USER ]] && POSTFIX_RELAYHOST_USER=$RELAYHOST_USER || POSTFIX_RELAYHOST_USER="your-gmail-user"
[[ -e $RELAYHOST_PASSWORD ]] && POSTFIX_RELAYHOST_PASSWORD=$RELAYHOST_PASSWORD || POSTFIX_RELAYHOST_PASSWORD="12345678"

# POSTFIX configuration
[[ -e $INET_INTERFACE ]] && POSTFIX_INET_INTERFACE=$INET_INTERFACE || POSTFIX_INET_INTERFACE="all"
[[ -e $MYNETWORK_STYLE ]] && POSTFIX_MYNETWORK_STYLE=$MYNETWORK_STYLE || POSTFIX_MYNETWORK_STYLE="host"
[[ -e $MYNETWORKS ]] && POSTFIX_MYNETWORKS=$MYNETWORKS || POSTFIX_MYNETWORKS="all"
[[ -e $MYHOSTNAME ]] && POSTFIX_MYHOSTNAME=$MYHOSTNAME|| POSTFIX_MYHOSTNAME="all"
[[ -e $MYDOMAIN ]] && POSTFIX_MYDOMAIN=$MYDOMAIN || POSTFIX_MYNETWORKS="your-domain.com"

cat $WORKDIR/main.cf >> /etc/postfix/main.cf 









