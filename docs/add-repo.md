1. Generate key: `flux create secret git [secret-name] --export --url=ssh://git@github.com/[user]/[repository] --ssh-key-algorithm=rsa --ssh-rsa-bits=4096 > [filename.yaml]`
2. get public key `yq eval '.stringData."identity.pub"' [filename.yaml]`
3. `sops --encrypt --in-place [filename.yaml]`
4. add deploy key to repo
5. 