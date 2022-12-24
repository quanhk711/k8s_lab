# Get acquainted with kubectl
**Tips**:   
you can use the alias for kubectl to make your fingers less active.  
```bash
vi ~/.bashrc 
	# declare the following 
	alias k='kubectl'
	alias kd='kubectl describe'
	alias ns='kubectl config set-context --current --namespace'
```
**abbreviation k8s**.  
| command  | abbreviation  |
|:----------|:----------|
| node    | no   |
| pod| po    |
| service    | svc    |




1. display a list of contexts
```bash
kubectl config get-contexts
```
2. display the current-context
```bash
kubectl config current-context
```
3. permanently save the namespace for all subsequent kubectl commands in that context
```bash
kubectl config set-context --current --namespace=default
# or use an alias
ns default
```
4. get the status node
```bash
kubectl get node
	kubectl describe node  <node_name_here>
	# or use an alias
	kd node <node_name_here>
```
5. get the ram/CPU usage
```bash
kubectl get nodes | grep Ready | cut -d" " -f1 | xargs kubectl describe node | grep -E "Name: |cpu |memory"
```
6. list all resources in the namespace
```bash
kubectl get all
# or 
kubectl get all -n <namespace>
```
7. list many resources in the namespace
```bash
kubectl get service, po
# or
kubectl get no, service, po -n <namespace>
```
8. list the status of the pod
```bash
kubectl get po
	kubectl describe po <pod_name_here>
```
9. create the pod without yaml
```bash
kubectl run nginx --image=nginx --port=80 --restart=Never
```
and more at: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

# Practice
## debug 1
1. create multiple YAML objects from stdin
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox-sleep
spec:
  containers:
  - name: busybox
    image: busybox:1.2.1
EOF
```
2. check the pod
```bash
k get po
```
3. What's going on with the pod?
```bash
kd po <pod_name_here>
```
4. fix it.  
**hint**: you can check the image in docker hub.  

## debug 2
1. create multiple YAML objects from stdin
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox-sleep-2
spec:
  containers:
  - name: busybox
    image: busybox:1.28
EOF
```
2. check the pod
```bash
k get po
```
3. What's going on with the pod?
```bash
kd po <pod_name_here>
```
4. fix it.  
**hint**: google with keyword `pod status completed`

## create service
1. create service  node port
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: service-node-port
spec:
  type: NodePort
  selector:
    app: nginx-node-port
  ports:
    - port: 80
      targetPort: 80
      # Optional field
      # By default and for convenience, the Kubernetes control plane will allocate a port from a range (default: 30000-32767)
      nodePort: 30007
EOF
```
2. create pod nginx
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-node-port
  labels:
    app: nginx-node-port
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
      - containerPort: 80
EOF
```
3. access nginx
open browser with domain <ip_vm>:30007
4. get output JSON
```bash
k get po -o json
```
5. executing commands against pods
```bash
k exec -it nginx-node-port -- /bin/bash
    cat /etc/os-release
    exit
```
6. edit the pod and add 2nd container to pod
```bash
k get pod nginx-node-port -o yaml > edit-pod.yaml
    vim edit-pod.yaml
```
add 2nd container into the pod   
```yaml
  - image: quanhk711/nginx-hello:v1
    name: nginx-8080
    ports:
      - containerPort: 8080
    env:
    - name: VAR
      value: 06FCE6
```
apply with new config
```bash
k replace -f edit-pod.yaml --force
```
7. check the pod
```bash
k get po
```
8. create 2nd service  node port
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: service-node-port
spec:
  type: NodePort
  selector:
    app: nginx-node-port
  ports:
    - port: 8080
      targetPort: 8080
      # Optional field
      # By default and for convenience, the Kubernetes control plane will allocate a port from a range (default: 30000-32767)
      nodePort: 30008
EOF
```
9. access 2nd nginx
open browser with domain <ip_vm>:30008

10. delete pod
```bash
k delete pod nginx-node-port
```
