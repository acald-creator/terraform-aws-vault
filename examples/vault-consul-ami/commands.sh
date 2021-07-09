#!/usr/bin/env bash

sudo /opt/vault/bin/run-vault --tls-cert-file /opt/vault/tls/vault.crt.pem --tls-key-file /opt/vault/tls/vault.key.pem --enable-auto-unseal --auto-unseal-kms-key-id mrk-ec557a12097941eea625de511fc168dc --auto-unseal-kms-key-region us-east-2