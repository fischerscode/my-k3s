# Keycloak

- Keycloak is used to authenticate users.
- Realm `accounts` has alias `users`.
- Get the password of the admin user of the master realm by running
  ```bash
  kubectl get secret -n accounts credential-accounts --template={{.data.ADMIN_PASSWORD}} | base64 -d | pbcopy
  ```


# Export users
(Credit: https://gist.github.com/axdotl/c1f97e62c18294e8de550fa5d2ac4661)
```bash
kubectl exec POD_NAME -- /opt/jboss/keycloak/bin/standalone.sh \
    -Dkeycloak.migration.action=export \
    -Dkeycloak.migration.realmName=users \
    -Dkeycloak.migration.provider=dir \
    -Dkeycloak.migration.dir=/tmp/keycloak-export \
    -Dkeycloak.migration.usersExportStrategy=DIFFERENT_FILES \
    -Dkeycloak.migration.usersPerFile=1000 \
    -Djboss.http.port=8888 \
    -Djboss.https.port=9999 \
    -Djboss.management.http.port=7777 \
    -Djboss.management.https.port=7776

kubectl cp POD_NAME:/tmp/keycloak-export .
```