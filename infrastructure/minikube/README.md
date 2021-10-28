```
minikube start --memory 16384 --cpus 6
```

```bash
export BASE_DOMAIN=minikube.local 
export SECRET_KEYCLOAK_DOMAIN=accounts.example.com
kustomize build | envsubst | kubectl apply -f - # Wait a little bit and then run again
```

Start load balancer: `sudo minikube tunnel` (Sudo for 80 & 443)