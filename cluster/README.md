1. Starting up virtual lab (1 controller + 2 nodes)
```bash
vagrant up
```

2. Install tools
```bash
vagrant ssh controller-1
cd /vagrant
sudo bash scripts/install_tools.sh
```

3. Provisioning CA & Certificates & Configuration
```bash
vagrant ssh controller-1
cd /vagrant
sudo bash scripts/provision_cert_and_cfg.sh
```

4. Setting up etcd
```bash
vagrant ssh controller-1
cd /vagrant/
sudo bash scripts/etcd.sh
```

5. Bootstrap control plane
```bash
vagrant ssh controller-1
cd /vagrant
sudo bash scripts/bootstrap-control-plane.sh
```

6. Setting up nodes (Do the same to all worker nodes)
```bash
vagrant ssh worker-1
cd /vagrant
sudo bash scripts/bootstrap-worker.sh
```
7. Deploy Calico CNI
vagrant ssh controller-1
cd /vagrant
sudo bash scripts/deploy-calico-cni.sh
# Verify 
```bash
vagrant ssh controller-1
export KUBECONFIG=/vagrant/artifacts/cfg/admin.kubeconfig
kubectl run alpine --image=alpine:latest --command -- sleep 3600
```
