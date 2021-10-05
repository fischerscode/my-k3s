#!/bin/bash

echo -n "Docker username: "
read dockerUsername
echo -n "Docker password or access token: "
read -s dockerPassword
kubectl create secret docker-registry docker-cred --docker-server=https://index.docker.io/v1/ --docker-username=$dockerUsername --docker-password=$dockerPassword --dry-run=client -o yaml > infrastructure/$CLUSTER/docker-cred/docker-cred.sops.yaml; sops --encrypt --in-place infrastructure/$CLUSTER/docker-cred/docker-cred.sops.yaml

echo "metallb:"
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(tools/generate_password.sh 128)" --dry-run=client -o yaml > infrastructure/$CLUSTER/metallb/memberlist.yaml; sops --encrypt --in-place infrastructure/$CLUSTER/metallb/memberlist.yaml

echo "PDNS:"
tools/generate_password.sh 128 > infrastructure/$CLUSTER/pdns/mariadb-auth-root.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/pdns/mariadb-auth-root.encrypted
tools/generate_password.sh 128 > infrastructure/$CLUSTER/pdns/mariadb-auth-user.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/pdns/mariadb-auth-user.encrypted
tools/generate_password.sh 128 > infrastructure/$CLUSTER/pdns/mariadb-admin-root.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/pdns/mariadb-admin-root.encrypted
tools/generate_password.sh 128 > infrastructure/$CLUSTER/pdns/mariadb-admin-user.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/pdns/mariadb-admin-user.encrypted
tools/generate_password.sh 128 > infrastructure/$CLUSTER/pdns/pdns-api-key.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/pdns/pdns-api-key.encrypted
tools/generate_password.sh 128 > infrastructure/$CLUSTER/pdns/pdns-admin-secret-key.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/pdns/pdns-admin-secret-key.encrypted
docker run --rm -ti python /bin/bash -c "pip3 -q install bcrypt 2> /dev/null && python -c 'import bcrypt; print(bcrypt.gensalt().decode(), end = \"\")'" > infrastructure/$CLUSTER/pdns/pdns-admin-salt.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/pdns/pdns-admin-salt.encrypted

echo "Monitoring:"
echo -n "Slack webhook for monitoring: "; read webHook; printf $webHook > infrastructure/$CLUSTER/monitoring/slack-webhook.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/monitoring/slack-webhook.encrypted
tools/generate_password.sh 128 > infrastructure/$CLUSTER/monitoring/grafana-admin-password.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/monitoring/grafana-admin-password.encrypted

echo "Traefik:"
echo -n "Traefik pilot token: "; read token; printf $token > infrastructure/$CLUSTER/traefik/pilot-token.encrypted; sops --encrypt --in-place infrastructure/$CLUSTER/traefik/pilot-token.encrypted
echo "Traefik dashboard admin password:"; htpasswd -nB admin > infrastructure/$CLUSTER/traefik/traefik-dashboard-users.txt