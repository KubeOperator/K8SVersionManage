#!/usr/bin/env bash


os=`uname -m`
if [ ${os} =~ "x86_64" ];then
  architectures="amd64"
elif [ uname -m =~ "aarch64" ]; then
    
k8s_version = $1
baseUrl="https://kubeoperator.fit2cloud.com/k8s/${k8s_version}/amd64/"

#https://kubeoperator.fit2cloud.com/k8s/v1.18.12/amd64/k8s.tar.gz

k8s_packages=(
  k8s.tar.gz
  kube-controller-manager.tar
  pause.tar
  kube-scheduler.tar
  kube-apiserver.tar
  kube-proxy.tar
)

for i in "${k8s_packages[@]}"
  do
    echo "wget $baseUrl/$i"
  done