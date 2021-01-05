#!/usr/bin/env bash

CURRENT_DIR=$(
   cd "$(dirname "$0")"
   pwd
)
set -e
os=`uname -m`
k8s_version=$1

if [ "${k8s_version}" == "" ];then
  echo "请输入k8s版本号,例: ./build.sh v1.18.10"
  exit 0
fi

if [ ${os} == "x86_64" ];then
  architectures="amd64"
elif [ ${os} == "aarch64" ];then
  architectures="arm64"
fi

save_dir=${CURRENT_DIR}/${k8s_version}_offline
mkdir -p ${save_dir}
baseUrl="https://kubeoperator.fit2cloud.com/k8s/${k8s_version}/${architectures}"
sed -i -e "s#architectures=.*#architectures=${architectures}#g" upload.sh
sed -i -e "s#k8s_version=.*#k8s_version=${k8s_version}#g" upload.sh


k8s_packages=(
  k8s.tar.gz
  kube-controller-manager.tar
  pause.tar
  kube-scheduler.tar
  kube-apiserver.tar
  kube-proxy.tar
)

for p in "${k8s_packages[@]}"
  do
    curl -L -o ${save_dir}/${p}  $baseUrl/${p}
    if [ $? -eq 0 ];then
    echo -e "====== ${p}  is saved successfully ======\n"
    fi
  done
\cp -rp upload.sh ${save_dir}/

tar zcvf ${k8s_version}_offline.tar.gz ${k8s_version}_offline 1> /dev/null
if [ $? -eq 0 ];then
  echo "Packaged successfully!"
fi