#!/bin/sh

# https://devcenter.heroku.com/articles/ssl-certificate-self
# http://cunning.sharp.fm/2008/06/importing_private_keys_into_a.html
# http://stackoverflow.com/questions/2685512/can-a-java-key-store-import-a-key-pair-generated-by-openssl

echo "removing old stuff"
rm *.crt *.key *.csr keystore


echo "generating private key"

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

# openssl genrsa -des3   -passout pass:pazzword -out server.protected.key 2048   # heroku
# openssl genrsa -aes128 -out server.private.key 2048
openssl genrsa -out server.private.key 2048


echo "generating a certificate signing request"
# req - PKCS#10 certificate request and certificate generating utility.
# -new this option generates a new certificate request.
openssl req -new -key server.private.key -out server.csr -subj "/C=IT/ST=Milan/L=Milan/O=DaniDemi/OU=IT Department/CN=miserve.com"

echo "generating a certificate"
# The x509 command is a multi purpose certificate utility. 
# It can be used to display certificate information, convert certificates to various forms, sign certificate requests like a "mini CA" or edit certificate trust settings.
# -req by default a certificate is expected on input. With this option a certificate request is expected instead.
# -signkey filename this option causes the input file to be self signed using the supplied private key.
# If the input is a certificate request then a self signed certificate is created using 
# the supplied private key using the subject name in the request.
openssl x509 -req -days 9999 -in server.csr -signkey server.private.key -out server.crt

echo "dump the certificate"
openssl x509 -in server.crt -text

openssl pkcs12 -export -in server.crt -inkey server.private.key -out server.p12 -name miserve -CAfile ca.crt -caname root

#echo "importing the certificate in a new keystore"
#keytool -keystore keystore -import -alias miserve -file server.crt -trustcacerts <<-EOF
#	pazzword
#	pazzword
#	yes
#EOF

keytool -importkeystore \
        -deststorepass pazzword -destkeypass pazzword -destkeystore keystore \
        -srckeystore server.p12 -srcstoretype PKCS12 -srcstorepass some-password \
        -alias some-alias

#After creating the key and the certificate with OpenSSL, use OpenSSL to create a PKCS #12 key store:
openssl pkcs12 -export -in cert.pem -inkey key.pem > server.p12

# Then convert this store into a Java key store
keytool -importkeystore -srckeystore server.p12 -destkeystore server.jks -srcstoretype

keytool -importkeystore -deststorepass changeit -destkeypass changeit -destkeystore my-keystore.jks -srckeystore cert-and-key.p12 -srcstoretype PKCS12 -srcstorepass cert-and-key-password -alias 1



# http://stackoverflow.com/questions/2685512/can-a-java-key-store-import-a-key-pair-generated-by-openssl

mv *.crt ../../../secrets
mv *.key ../../../secrets
mv *.csr ../../../secrets
mv keystore ../../../secrets