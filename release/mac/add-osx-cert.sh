#!/usr/bin/env sh

KEY_CHAIN=build.keychain
CERTIFICATE_P12=release_script/mac_only/Certificates.p12

#create a keychain
security create-keychain -p travis $KEY_CHAIN

# Make the keychain the default so identities are found
security default-keychain -s $KEY_CHAIN

# Unlock the keychain
security unlock-keychain -p travis $KEY_CHAIN

security import $CERTIFICATE_P12 -k $KEY_CHAIN -P $CERTIFICATE_PASSWORD -T /usr/bin/codesign;

security set-key-partition-list -S apple-tool:,apple: -s -k travis $KEY_CHAIN

# remove certs
rm -fr $CERTIFICATE_P12