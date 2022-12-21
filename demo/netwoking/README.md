# Kubernetes network stack fundamentals
Learn how containers communicate within a pod through the same Kubernetes network namespace

## How containers inside a pod communicate
A multi-container pod
```bash
kubectl apply -f nginx_busybox.yaml
kubectl get pods
kubectl exec -it -c busybox nginx-busybox -- /bin/sh
    wget localhost -O - 2>/dev/null
    netstat -tnlp
```