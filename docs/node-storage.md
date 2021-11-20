List images on node: `sudo k3s crictl images`
Clean unused images: `sudo k3s crictl rmi --prune`

`ansible all -i inventory-contabo1.yaml -a "k3s crictl rmi --prune" -b`