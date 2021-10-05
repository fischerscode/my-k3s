**THIS PROJECT IS STILL WORK IN PROGRESS**

# my-k3s
The configuration and automatation of a k3s cluster.

<!-- # Setup
1. Setup the servers using `ansible-playbook main.yml --extra-vars=cluster_name=contabo_1`.
2. Get kubeconfig: `ansible-playbook tools/get_kubeconfig.yml --extra-vars=cluster_name=contabo_1`
3. Port forward API-Server `ssh -L 6443:10.1.0.1:6443 172.16.17.101`
4. kubeconfig server
5. `KUBECONFIG=kubeconfig-vagrant.yaml`
6. Setup Flux:
   1. Make sure GITHUB_TOKEN is set. Run `export GITHUB_TOKEN=$(pbpaste)` with a personal access token (everything in repo is enabled) in your clipboard.
   2. For vagrant: `flux bootstrap github --owner=fischerscode --repository=my-k3s --path=clusters/vagrant --branch master --personal`

      For contabo_1: `flux bootstrap github --owner=fischerscode --repository=my-k3s --path=clusters/contabo_1 --branch master --personal` -->


<!-- # Testing
You can test this repository using vagrant.
1. `vagrant up`
2. `ansible-playbook tools/store_known_hosts.yml`
3. `ansible-playbook main.yml --extra-vars=cluster_name=vagrant`
4. Make sure GITHUB_TOKEN is set. Run `export GITHUB_TOKEN=$(pbpaste)` with a personal access token (everything in repo is enabled) in your clipboard.
5. `flux bootstrap github --owner=fischerscode --repository=my-k3s --path=clusters/vagrant --branch master --personal` -->


## Flux
Flux is used to automatically provision the manifests.

### Install Flux
MacOS: ```brew install fluxcd/tap/flux```


<!-- # Velero
Velero is used to backup the cluster.

## Install Velero
MacOS: ```brew install velero``` -->


<!-- ## Partition
1. start Rescue system (ArchRescue)
2. ssh as root
3. `fdisk -l`
4. `e2fsck -f /dev/sda3 -y`
5. `resize2fs /dev/sda3 100663296s`
6. `parted /dev/sda`
7. `unit s`
8. Print current config: `print free`
9. Shrink 3 by 150GB (215-150=65) `resizepart 3 104857599s` 
10. `mkpart logical 104857600s 419430366s` (104857600 = 419430400 - 150 * 1024^3 /512)
11. Print current config: `print free`
12. `reboot` -->

## New Cluster
1. Specify cluster name: `export CLUSTER=`
2. Setup ansible vault and store the vault password in `$CLUSTER-ansible.key`
3. Create inventory: `cp inventory-sample.yaml inventory-$CLUSTER.yaml`
4. Edit your inventory (Generate vault entries using `pbpaste | ansible-vault encrypt_string --vault-password-file $CLUSTER-ansible.key --name k3sToken`. `--name` has to be the name of the encrypted key.)
5. Copy cluster manifests: `cp -r clusters/sample clusters/$CLUSTER`
6. Edit `clusters/$CLUSTER/infrastructure.yaml` manifest
7. Copy infrastructure: `cp -r infrastructure/sample infrastructure/$CLUSTER`
8. Generate files: `ansible-playbook -i inventory-$CLUSTER.yaml tools/generate_files.yml --extra-vars=cluster_name=$CLUSTER`
9.  [Setup SOPS](#mozilla-sops)
10. Create secrets: `./generate-secrets.sh`
11. Store known hosts: `ansible-playbook -i inventory-$CLUSTER.yaml tools/store_known_hosts.yml`
12. Install k3s (wait until it hangs at 'Enable and check K3s service'): `ansible-playbook -i inventory-$CLUSTER.yaml main.yml --extra-vars=cluster_name=$CLUSTER --vault-password-file $CLUSTER-ansible.key`
13. Get access to the cluster:
    1.   New terminal and `export CLUSTER=` again.
    2.  Get kubeconfig: `ansible-playbook -i inventory-$CLUSTER.yaml tools/get_kubeconfig.yml --extra-vars=cluster_name=$CLUSTER`
    3.  Tunnel api server: `ssh -L 6443:10.1.0.1:6443 IP_OF_A_MASTER`
    4.  New terminal and `export CLUSTER=` again.
    5.  Replace IP at server in `kubeconfig-$CLUSTER.yaml` with `127.0.0.1`.
    6.  Use config: `KUBECONFIG=kubeconfig-$CLUSTER.yaml`
14. Setup Flux:
    1. Make sure GITHUB_TOKEN is set. Run `export GITHUB_TOKEN=$(pbpaste)` with a personal access token (everything in repo is enabled) in your clipboard.
    2. Setup flux: `flux bootstrap github --owner=fischerscode --repository=my-k3s --path=clusters/$CLUSTER --branch master --personal`
15. Playbook should finish now. If not check `flux get all`.
16. Replace IP at server in `kubeconfig-$CLUSTER.yaml` with `kubernetes_api_public_address`.
   
### Afterwards:
1. Add cluster to `.github/workflows/update-flux.yaml`
2. get grafana admin password: `kubectl get secret -n monitoring grafana-cred --template={{.data.ADMIN_PASSWORD}} | base64 -d | pbcopy`

## Mozilla SOPS
1. `brew install gnupg sops`
2. Generate a GPG/OpenPGP key with no passphrase (%no-protection):
   ```
   export KEY_NAME="$CLUSTER.my-k3s.fischerscode.com"
   export KEY_COMMENT="flux secrets"

   gpg --batch --full-generate-key <<EOF
   %no-protection
   Key-Type: 1
   Key-Length: 4096
   Subkey-Type: 1
   Subkey-Length: 4096
   Expire-Date: 0
   Name-Comment: ${KEY_COMMENT}
   Name-Real: ${KEY_NAME}
   EOF
   ```
3. `gpg --list-keys "${KEY_NAME}"`
4. Store the fingerprint: `export KEY_FP=`
5. Backup private key:
   1. To file: `gpg --export-secret-keys --armor ${KEY_NAME} > $CLUSTER.key` (Ansible will search for this key and apply it as a secret if present.)
   2. To clipboard: `gpg --export-secret-keys --armor ${KEY_NAME} | pbcopy`
6. Add public key to git: `gpg --export --armor ${KEY_NAME} > ./clusters/$CLUSTER/.sops.pub.asc`
7. ```
   cat <<EOF >> .sops.yaml
     - path_regex: /$CLUSTER\/.*\.yaml$
       encrypted_regex: ^(data|stringData)$
       pgp: ${KEY_FP}
     - path_regex: /$CLUSTER\/.*\.encrypted$
       pgp: ${KEY_FP}
   EOF
   ```

### Optional:
9.  Remove private key: `gpg --delete-secret-keys ${KEY_NAME}`
10. Import secret key: `gpg --import $CLUSTER.key`
