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
## How container different pod communicate
```bash
kubectl apply -f nginx.yaml
kubectl apply -f busybox.yaml

kubectl get pods
kubectl get pod nginx-1 --template '{{.status.podIP}}'
kubectl exec -it busybox-1 -- /bin/sh
    ping <ip-nginx-1>
    wget <ip-nginx-1> -O - 2>/dev/null
```
## How pod to service communicate
### ref:https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
```bash
kubectl apply -f nginx-service.yaml
kubectl apply -f busybox.yaml

kubectl get pods
kubectl exec -it busybox-1 -- /bin/sh
    wget nginx-service.default.svc.cluster.local -O - 2>/dev/null
```