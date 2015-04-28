#!/bin/sh

# https://devcenter.heroku.com/articles/ssl-certificate-self
# http://cunning.sharp.fm/2008/06/importing_private_keys_into_a.html
# http://stackoverflow.com/questions/2685512/can-a-java-key-store-import-a-key-pair-generated-by-openssl

echo "removing old stuff"
rm *.crt *.key *.csr *.p12 keystore

echo "Generating private key"
openssl genrsa -out server.private.key 2048

echo "Generating a Certificate Signing Request"
openssl req -new -key server.private.key -out server.csr -subj "/C=IT/ST=Milan/L=Milan/O=DaniDemi/OU=IT Department/CN=mywebsite"

echo "Self signing the certificate"
openssl x509 -req -days 9999 -in server.csr -signkey server.private.key -out server.crt

echo "Dumping the certificate"
openssl x509 -in server.crt -text

echo "Including private key and certificate to a pkcs12"
openssl pkcs12 -export -in server.crt -inkey server.private.key -out server.p12 -name mywebsite -CAfile ca.crt -caname root -password pass:pazzword

echo "Importing it into a Java keystore"
keytool -importkeystore \
        -deststorepass pazzword -destkeypass pazzword -destkeystore keystore \
        -srckeystore server.p12 -srcstoretype PKCS12 -srcstorepass pazzword \
        -alias mywebsite
        
echo "Listing content of keystore"        
keytool -list -keystore keystore -storepass pazzword
        
echo "Moving things to right place"
mv *.p12 ../../../secrets
mv *.crt ../../../secrets
mv *.key ../../../secrets
mv *.csr ../../../secrets
mv keystore ../../../secrets