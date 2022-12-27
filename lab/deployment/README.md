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
| deployment    | deploy    |
| replicaset    | rs    |


## kubectl commands
`kubectl get nodes`

`kubectl get pod`

`kubectl get services`

`kubectl create deployment nginx-depl --image=nginx`

`kubectl get deployment`

`kubectl get replicaset`

`kubectl edit deployment nginx-depl`

## debugging
`kubectl logs {pod-name}`

`kubectl exec -it {pod-name} -- bin/bash`

## create mongo deployment
`kubectl create deployment mongo-depl --image=mongo`

`kubectl logs mongo-depl-{pod-name}`

`kubectl describe pod mongo-depl-{pod-name}`

## delete deplyoment
`kubectl delete deployment mongo-depl`

`kubectl delete deployment nginx-depl`

## create or edit config file
`vim nginx-deployment.yaml`

`kubectl apply -f nginx-deployment.yaml`

`kubectl get pod`

`kubectl get deployment`

## delete with config
`kubectl delete -f nginx-deployment.yaml`

# Practice
## create replicaset
1. create replicaset nginx
```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx
EOF
```
2. create new pod with the same label
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pod-single
  labels:
    app: pod-single
    tier: frontend
spec:
  containers:
  - name: busybox
    image: busybox:1.2.1
EOF
```
3. see what will happen

4. delete replicaset 
```bash
kubectl delete replicaset.apps/frontend
```

## create deployment
1. create deployment nginx
```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
EOF
```

2. update deployment
```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.23
	kubectl rollout status deployment/nginx-deployment 
	# or
	kubectl get rs -w
```

3. scaling deployment
```bash
kubectl scale deployment/nginx-deployment --replicas=10
```

4. get revision deployment
```bash
kubectl rollout history deployment/nginx-deployment
```

5. rollback to a specific revision by specifying it with --to-revision
```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=<number_revision>
```

5. patch deployment
```bash
cat <<EOF > patch.yaml
spec:
  replicas: 1
EOF
kubectl patch deployment nginx-deployment --patch "$(cat patch.yaml)"
```