#!/usr/bin/env bash

set -euxo pipefail

function remove_misc() {
  apt-get remove -y \
    net-tools jq git golang socat conntrack ipset
  apt autoremove
}

function uninstall_cfssl() {
  if [[ ! -f /usr/local/bin/cfssl ]]
  then
    rm -rf /usr/local/bin/cfssl
  fi

  if [[ ! -f /usr/local/bin/cfssljson ]]
  then
    rm -rf /usr/local/bin/cfssljson
  fi
}

function uninstall_kubectl() { 
  if [[ ! -f /usr/local/bin/kubectl ]]
  then
    rm -rf /usr/local/bin/kubectl
  fi
}

function uninstall_helm() {
  if [[ ! -f /usr/local/bin/helm ]]
  then
    rm -rf /usr/local/bin/helm
  fi
}

function remove_etcd() {
    systemctl daemon-reload
    systemctl stop etcd.service
    rm -rf /etc/systemd/system/etcd.service /etc/etcd /var/lib/etcd /usr/local/bin/etcd
}

function remove_kube_apiserver() {
    systemctl daemon-reload
    systemctl stop kube-apiserver.service
    rm -rf /etc/systemd/system/kube-apiserver.service /var/lib/kubernetes/*.pem

}

function remove_controller_manager() {
  systemctl daemon-reload
  systemctl stop kube-controller-manager.service
  rm -rf /etc/systemd/system/kube-controller-manager.service /var/lib/kubernetes/kube-controller-manager.kubeconfig
}

function remove_kube_scheduler() {
  systemctl daemon-reload
  systemctl stop kube-scheduler
  rm -rf /etc/systemd/system/kube-scheduler.service /var/lib/kubernetes/kube-scheduler.kubeconfig
}

function remove_binary_control_plan() {
    rm -rf /usr/local/bin/kube*
}

function remove_cni_plugins() {  
  for _dir in /etc/cni/net.d /opt/cni/bin
  do
    if [[ ! -d ${_dir} ]]
    then
      rm -rf ${_dir} 
    fi
  done
}

function remove_kubelet() {
  for _dir in /var/lib/kubelet /var/lib/kubernetes/ /var/run/kubernetes /etc/systemd/system/kubelet.service.d/
  do
    if [[ ! -d ${_dir} ]]
    then
      rm -rf ${_dir}
    fi
  done

  systemctl daemon-reload
  systemctl stop kubelet
  rm -rf /etc/systemd/system/kubelet.service /usr/local/bin/kubelet/*.kubeconfig
}

function remove_kube_proxy() {
  if [[ ! -d /var/lib/kube-proxy ]]
  then
      rm -rf /var/lib/kube-proxy
  fi

  if [[ ! -f /usr/local/bin/kube-proxy ]]
  then
    rm -rf /usr/local/bin/kube-proxy /var/lib/kube-proxy/kubeconfig/kube-proxy.kubeconfig
  fi
    systemctl daemon-reload
    systemctl stop kube-proxy
}

function remove_containerd() {
  systemctl daemon-reload
  systemctl stop containerd
  rm -rf  /etc/containerd/ /bin/containerd* /usr/local/bin/runc /usr/local/bin/crictl /etc/systemd/system/containerd.service /etc/containerd/config.toml
}

# remove_misc
# uninstall_cfssl
# uninstall_kubectl
# uninstall_helm
# remove_etcd
# remove_kube_apiserver
# remove_controller_manager
# remove_kube_scheduler
# remove_binary_control_plan
remove_cni_plugins
remove_kubelet
remove_kube_proxy
remove_containerd
