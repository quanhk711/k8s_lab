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
| service    | svc   |
| deployment    | deploy  |
# Create data in pod without mount volume
1. create deployment with relica=2
```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: datatest-deployment
spec:
  selector:
    matchLabels:
      app: datatest-deployment
  replicas: 2
  template:
    metadata:
      labels:
        app: datatest-deployment
    spec:
      containers:
      - name: service
        image: ubuntu:xenial
        command: [ "/bin/sh" , "-c", "tail -f /dev/null" ]
EOF
```
2. exec to pod
```bash
kubectl exec -it <pod_name> -- bash
    mkdir test.txt
```
3. check the file create above in another pod 

# Setup NFS server for storage backend 
1. install nfs
```bash
apt update 
apt -y upgrade
apt install -y nfs-server
mkdir /data
chmod 777 /data
```
```bash
cat << EOF >> /etc/exports
/data 192.168.56.10(rw,no_subtree_check,no_root_squash)
EOF
```

```bash
systemctl enable --now nfs-server
exportfs -ar
```

2. Prepare Kubernetes worker nodes
```bash
apt install -y nfs-common
```
# Using NFS in Kubernetes
## Method 1 — Connecting to NFS directly with Pod manifest
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-1
  labels:
    app: test-volume
spec:
  containers:
    - name: alpine
      image: alpine:latest
      command:
        - touch
        - /data/test1
      volumeMounts:
        - name: nfs-volume
          mountPath: /data
  volumes:
    - name: nfs-volume
      nfs:
        server: controller
        path: /data
        readOnly: no
EOF
```
## Method 2 — Connecting using the PersistentVolume resource
1. crate PV
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-volume
  labels:
    app: test-volume
spec:
  accessModes:
    - ReadWriteOnce
    - ReadOnlyMany
    - ReadWriteMany
  capacity:
    storage: 2Gi
  storageClassName: ""
  persistentVolumeReclaimPolicy: Recycle
  volumeMode: Filesystem
  nfs:
    server: controller
    path: /data
    readOnly: no
EOF
```
2. create PVC
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pv-claim
spec:
  storageClassName: ""
  volumeName: nfs-volume
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```
3. Linking Persistent Volumes to Pods
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-2
  labels:
    app: test-volume
spec:
  containers:
    - name: alpine
      image: alpine:latest
      command:
        - touch
        - /data/test2
      volumeMounts:
      - mountPath: /data
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: test-pv-claim
EOF
```
## Method 3 — Dynamic provisioning using StorageClass
1. add helm repo
```bash
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
```

2. install NFS provisioner
```bash
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --create-namespace \
  --namespace nfs-provisioner \
  --set nfs.server=controller \
  --set nfs.path=/data
```
3. create PVC from storage class
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-sc-test
  labels:
    storage.k8s.io/name: nfs
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-client
  resources:
    requests:
      storage: 1Gi
EOF
```
4. create new deployment with mounted the `PersistentVolumeClaim` above

5. exec to pod
```bash
kubectl exec -it <pod_name> -- bash
    mkdir test.txt
```
6. check the file create above in another pod 

# play with secret and config map
1. create new secret
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  USER_NAME: YWRtaW4=
  PASSWORD: MWYyZDFlMmU2N2Rm
EOF
```
2. mount the secret into the pod via `Environment variable`
```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secret-deployment
spec:
  selector:
    matchLabels:
      app: secret-deployment
  replicas: 2
  template:
    metadata:
      labels:
        app: secret-deployment
    spec:
      containers:
      - name: service
        image: ubuntu:xenial
        command: [ "/bin/sh" , "-c", "tail -f /dev/null" ]
        envFrom:
        - secretRef:
            name: mysecret
EOF
```