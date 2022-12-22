1. Starting up virtual lab (1 controller)
```bash
vagrant up
```
if provisioning fail!
```bash
vagrant reload controller 
```
update VM
```bash
vagrant reload controller --provision
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
sudo bash scripts/provision_cert_single_node.sh
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
6. Install Kubelet, Containerd, runc
```bash
cd /vagrant
sudo bash scripts/bootstrap-kubelet-cr.sh
```
# Verify 
```bash
export KUBECONFIG=/vagrant/artifacts/cfg/admin.kubeconfig
kubectl get node
kubectl run alpine --image=alpine:latest --command -- sleep 3600
```
