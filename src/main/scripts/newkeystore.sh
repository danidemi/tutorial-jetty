#!/bin/sh

# https://devcenter.heroku.com/articles/ssl-certificate-self

echo "removing old stuff"
rm *.crt *.key *.csr keystore


echo "generating private & public key pair"

# You can choose to encrypt the private key with a symmetric algorithm. If algorithm is not specified, private key is not protected.

# AES is the successor of DES as standard symmetric encryption algorithm for US federal organizations. 
# AES uses keys of 128, 192 or 256 bits, although, 128 bit keys provide sufficient strength today. 
# It uses 128 bit blocks, and is efficient in both software and hardware implementations. 
# It was selected through an open competition involving hundreds of cryptographers during several years.

# DES is the previous "data encryption standard" from the seventies. 
# Its key size is too short for proper security. 
# The 56 effective bits can be brute-forced, and that has been done more than ten years ago. 
# DES uses 64 bit blocks, which poses some potential issues when encrypting several gigabytes of data with the same key.

# 3DES is a way to reuse DES implementations, by chaining three instances of DES with different keys. 
# 3DES is believed to still be secure because it requires 2^112 operations which is not achievable with foreseeable technology. 
# 3DES is very slow especially in software implementations because DES was designed for performance in hardware.

# The last number is the size of the key in bits, defaults to 512

# openssl genrsa -aes128 -passout pass:pazzword -out server.protected.key 2048   # mine
# openssl genrsa -des3   -passout pass:pazzword -out server.protected.key 2048   # heroku

echo "removing password protection from private key"
openssl rsa -in server.protected.key -out server.unprotected.key -passin pass:pazzword

echo "generating a certificate signing request"
openssl req -new -key server.unprotected.key -out server.csr -subj "/C=IT/ST=Milan/L=Milan/O=DaniDemi/OU=IT Department/CN=miserve.com"

echo "generating a certificate"
openssl x509 -req -days 365 -in server.csr -signkey server.unprotected.key -out server.crt

echo "importing the certificate in a new keystore"
keytool -keystore keystore -import -alias miserve -file server.crt -trustcacerts <<-EOF
	pazzword
	pazzword
	yes
EOF

mv *.crt ../../../secrets
mv *.key ../../../secrets
mv *.csr ../../../secrets
mv keystore ../../../secrets