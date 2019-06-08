#/bin/bash -x

# This script generates CA and Device CERT
# @Author: nzvincent@gmail.com
# Usage:
# ./gen-rootca-ssl.sh

BACKUP=backup-`date '+%Y%m%d%H%M%S'`
mkdir -p ${BACKUP}
 [ -d ${BACKUP}x ] && cp -pv *.csr *.key *.crt ${BACKUP} || echo "Backup directory ${BACKUP} not found, please ensure you've write permission to current folder."; exit 127

CA_DNS=ca.example.com
HOST_DNS=www.example.com
CA_KEY_PASS="topsecret"
HOST_KEY_PASS="lastsecret"

CITY=Wellington
COUNTRY=NZ
EMAIL=ca@example.com
ORG="Example Org"
UNIT="Example Unit"

# Subject Alternative Name ( SAN )
ALT_DNS="
DNS.1 = *.example.com
DNS.2 = www2.example.com
DNS.3 = www2.example.com"

CA_KEY=rootCA.key
CA_CRT=rootCA.crt
CA_CFN=rootCA.cfn

HOST_KEY=host.key
HOST_CSR=host.csr
HOST_CRT=host.crt
HOST_CFN=host.cfn

INDEX=index.txt
SERIAL=serial

echo > ${CA_CFN}
cat <<EOT >> ${CA_CFN}

  [ req ]
  prompt                  = no
  distinguished_name      = special_name

  [ special_name ]
  commonName              = ${CA_DNS}
  stateOrProvinceName     = ${CITY}
  countryName             = ${COUNTRY}
  emailAddress            = ${EMAIL}
  organizationName        = ${ORG}
  organizationalUnitName  = ${UNIT}

EOT

echo > ${HOST_CFN}
cat <<EOT >> ${HOST_CFN}

  [ req ]
  prompt                  = no
  distinguished_name      = special_name
  req_extensions          = req_ext

  [ special_name ]
  commonName              = ${HOST_DNS}
  stateOrProvinceName     = ${CITY}
  countryName             = ${COUNTRY}
  emailAddress            = ${EMAIL}
  organizationName        = ${ORG}
  organizationalUnitName  = ${UNIT}

  [ req_ext ]
  subjectAltName = @alt_names

  [alt_names]
  ${ALT_DNS}

EOT


h1 (){
  echo "#################################################"
  echo "# $@ "
  echo "#################################################"
  echo " "
  sleep 1
}


# update time server

############################################
# rootCA signer KEY / CERT
############################################
touch ${INDEX}
echo "1234" > ${SERIAL}

h1 "Create rootCA key"
openssl genrsa -aes256 \
  -passout pass:${CA_PASS} \
  -out ${CA_KEY} 2048 \

h1 "Generate rootCA cert"
openssl req -new -x509 -nodes \
  -sha256 \
  -days 3650 \
  -key ${CA_KEY}\
  -passin pass:${CA_PASS} \
  --config ${CA_CFN} \
  -out ${CA_CRT} \

h1  "Verify rootCA cert"
openssl x509 -noout -text \
  -in ${CA_CRT}

############################################
# Device's key and CSR
############################################
h1 "Create device's key"
openssl genrsa -aes256 \
  -passout pass:${HOST_PASS} \
  -out ${HOST_KEY} 2048

h1 "Generate device's csr"
openssl req -new \
  -key ${HOST_KEY} \
  -passin pass:${HOST_PASS} \
  -config ${HOST_CFN} \
  -out ${HOST_CSR}
  
h1 "Verify device's csr"
openssl req -noout -text \
  -in ${HOST_CSR}

############################################
# Device's Cert
############################################
h1 "Generate device's cert"
openssl x509 -req -sha256 \
  -days 730 \
  -in ${HOST_CSR} \
  -CA ${CA_CRT} \
  -CAkey ${CA_KEY} \
  -CAcreateserial \
  -passin pass:${CA_PASS} \
  -out ${HOST_CRT}

h1 "Verify device's cert"
openssl x509 -noout -text \
  -in ${HOST_CRT}
  
h1 "Secure private keys"
chmod 600 *.key

echo "Copy rootCA cert to your desktop / PC and import the cert to your OS or App trusted keystore"
echo "Keep your private keys and passphrase in a secure place"
echo "Install device's cert and key to your device. eg. Apache"
