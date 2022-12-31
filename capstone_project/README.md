# Overview
The purpose of the K8S capstone project is to give you a chance to combine what you've learned throughout the program.

# Instructions
## Step 1: Propose and Scope the Project
I suggest deploying quickapp on k8s: [https://github.com/emonney/QuickApp](url)

## Step 2: Choose either VM (single node) or K8s on cloud environment.
If you choose K8s on cloud, follow the steps below
1. install awscli 
[https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](url)

2. create AWS Access Key
[https://www.youtube.com/watch?v=vucdm8BWFu0](url)

3. config AWS Access Key
move to dowload dir, and run the command below
```bash
aws configure import --csv file://credentials.csv
```
4. install eksctl
[https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html](url)

5. verify
```bash
aws sts get-caller-identity
```

6. create the cluster config
```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: cluster-capstone-project
  region: us-east-1
nodeGroups:
  - name: eks-project-3
    labels: { role: workers }
    instanceType: m5.large
    desiredCapacity: 1
    minSize: 1
    maxSize: 1
```
7. create cluster
```bash
eksctl create cluster -f cluster.yaml
```
8. create your kubeconfig file with the AWS CLI
```bash
aws eks update-kubeconfig --region <aws_region> --name cluster-capstone-project
```
9. verify cluster
```bash
kubectl get node
```

## Step 3: Build your image's application and push to your docker registry

## Step 4: Deploy your application
1. deploy MySQL on k8s
[https://phoenixnap.com/kb/kubernetes-mysql](url)

2. create `ConfigMap` for DB ConnectionStrings
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: quickapp-configmap
data:
  ConnectionStrings__DefaultConnection: Server=mysql.default.svc.cluster.local,1433;Database=QuickApp_prod;User Id=sa;Password=Pass@word
```
3. create deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quickapp-deployment
  labels:     
    app: quickapp
spec:
  replicas: 1
  selector:
    matchLabels:       
      app: quickapp
  template:
    metadata:
      labels:         
        app: quickapp
    spec:
      containers:  
      - name: release-name-c
        image: <your_image_here>
        ports:
          - containerPort: 5000
          - containerPort: 443
        env:
        - name: ASPNETCORE_URLS
          value: "http://*:5000;https://+:443"
        - name: ASPNETCORE_HTTPS_PORT
          value: "443"
        envFrom:
        - configMapRef:
            name: quickapp-configmap
```
4. create service nodeport