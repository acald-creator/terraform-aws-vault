sudo vi /etc/hosts
<PRIVATE-IP> vault.phoenixveritas.com

readonly VAULT_TLS_CERT_FILE="/opt/vault/tls/vault.crt.pem"
readonly VAULT_TLS_KEY_FILE="/opt/vault/tls/vault.key.pem"

sudo /opt/vault/bin/run-vault --tls-cert-file "$VAULT_TLS_CERT_FILE" --tls-key-file "$VAULT_TLS_KEY_FILE"

sudo mkdir -pm 0755 /var/raft-node-1
sudo chown -R vault:vault /var/raft-node-1
sudo chmod -R a+rwx /var/raft-node-1

sudo mkdir -pm 0755 /var/vault-storage-file
sudo chown -R vault:vault /var/vault-storage-file
sudo chmod -R a+rwx /var/vault-storage-file

cat /opt/vault/config/default.hcl
ui = true

listener "tcp" {
  address         = "<PUBLIC-IP>:8200"
  cluster_address = "<PUBLIC-IP>:8201"
  tls_cert_file   = "/opt/vault/tls/vault.crt.pem"
  tls_key_file    = "/opt/vault/tls/vault.key.pem"
}

storage "file" {
 path = "/var/vault-storage-file"
}

ha_storage "raft" {
  path    = "/var/raft-node-1"
  node_id = "node1"
}

#storage "consul" {
#  address = "127.0.0.1:8500"
#  path    = "vault/"
#  scheme  = "http"
#  service = "vault"
#}

# HA settings
cluster_addr  = "https://<PRIVATE-IP>:8201"
api_addr      = "https://<PRIVATE-IP>:8200"

disable_mlock = true

sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault

export VAULT_ADDR="https://vault.phoenixveritas.com:8200"

vault operator init -key-shares=3 -key-threshold=2 > key.txt

Unseal Key 1: h2h8c6pxuAAFXfYPoiRBRV5rzcE13sIz7zegF/kw3Pai
Unseal Key 2: E/PHuQPgSoke1syI/PgRBnLLqxx8bWQhyZ/f8w20dFuu
Unseal Key 3: ndgh5zANyncsFizMLA97pjsfpfQac/L0RrPd2s/RWBQq

Initial Root Token: s.T6VENz92NMKbN2NunCzwcMv0

Vault initialized with 3 key shares and a key threshold of 2. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 2 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 2 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.

vault operator unseal $(grep 'Key 1:' key.txt | awk '{print $NF}')
vault operator unseal $(grep 'Key 2:' key.txt | awk '{print $NF}')

sudo systemctl status vault
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.849Z [INFO]  rollback: starting rollback manager
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.851Z [INFO]  core: restoring leases
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.852Z [INFO]  identity: entities restored
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.852Z [INFO]  identity: groups restored
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.852Z [INFO]  core: starting raft active node
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.852Z [INFO]  ha.raft: starting autopilot: config="&{false 0 10s 24h0m0s 1000 0 10s}" reconcile_interval=0s
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.852Z [INFO]  expiration: lease restore complete
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.852Z [INFO]  core.raft: creating new raft TLS config
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.853Z [INFO]  core: usage gauge collection is disabled
Jul 05 18:44:16 ip-10-0-0-14 vault[1698]: 2021-07-05T18:44:16.853Z [INFO]  core: post-unseal setup complete

vault login $(grep 'Initial Root Token:' key.txt | awk '{print $NF}')