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
mkdir -p ${save_dir}/{k8s,docker,etcd,containerd,helm,images,cni}

baseUrl="https://kubeoperator.fit2cloud.com"
sed -i -e "s#architectures=.*#architectures=${architectures}#g" upload.sh
sed -i -e "s#k8s_version=.*#k8s_version=${k8s_version}#g" upload.sh

case "$k8s_version" in
  v1.18.4) source versions/v1.18.4.sh ;;
  v1.18.6) source versions/v1.18.6.sh ;;
  v1.18.8) source versions/v1.18.8.sh ;;
  v1.18.10) source versions/v1.18.10.sh ;;
  v1.18.12) source versions/v1.18.12.sh ;;
  v1.18.14) source versions/v1.18.14.sh ;;
  v1.18.15) source versions/v1.18.15.sh ;;
  v1.18.18) source versions/v1.18.18.sh ;;
  v1.18.20) source versions/v1.18.20.sh ;;
  v1.20.4) source versions/v1.20.4.sh ;;
  v1.20.6) source versions/v1.20.6.sh ;;
  v1.20.8) source versions/v1.20.8.sh ;;
  v1.20.10) source versions/v1.20.10.sh ;;
esac

k8s_packages=(
  k8s.tar.gz
  kube-controller-manager.tar
  pause.tar
  kube-scheduler.tar
  kube-apiserver.tar
  kube-proxy.tar
)

docker_image=(
  `echo "docker.io/calico/typha:${calico_version}"`
  `echo "docker.io/calico/cni:${calico_version}"`
  `echo "docker.io/calico/node:${calico_version}"`
  `echo "docker.io/calico/kube-controllers:${calico_version}"`
  `echo "docker.io/calico/pod2daemon-flexvol:${calico_version}"`
  `echo "docker.io/calico/ctl:${calico_version}"`
  `echo "quay.io/coreos/flannel:${flannel_version}"`
  `echo "docker.io/coredns/coredns:${coredns_version}"`
  `echo "docker.io/traefik:${traefik_ingress_version}"`
  `echo "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${nginx_ingress_version}"`
  `echo "docker.io/kubeoperator/metrics-server:${metrics_server_version}"`
)

echo -e "====== KubeOperator build job is starting ======\n"
if [ "$architectures" == "amd64" ];then
  curl -L -o ${save_dir}/helm/helm-${helm_v2_version}-linux-${architectures}.tar.gz "${baseUrl}/helm/${helm_v2_version}/helm-${helm_v2_version}-linux-${architectures}.tar.gz"
  docker pull registry.cn-qingdao.aliyuncs.com/kubeoperator/tiller:${helm_v2_version}
  docker save registry.cn-qingdao.aliyuncs.com/kubeoperator/tiller:${helm_v2_version} -o "${save_dir}/images/tiller:${helm_v2_version}.tar"
  docker rmi registry.cn-qingdao.aliyuncs.com/kubeoperator/tiller:${helm_v2_version}
fi

# 缓存 k8s_packages
for p in "${k8s_packages[@]}"
  do
    curl -L -o ${save_dir}/k8s/${p}  "${baseUrl}/k8s/${k8s_version}/${architectures}/${p}"
    if [ $? -eq 0 ];then
    echo -e "====== ${p}  is saved successfully ======\n"
    fi
  done

# docker
for d in "${docker_image[@]}"
  do
    image_name=`echo $d|sed -r 's/.*\///'`
    docker pull $d
    docker save $d -o "${save_dir}/images/${image_name}.tar"
    docker rmi $d
  done

curl -L -o ${save_dir}/docker/docker-${docker_version}.tgz "${baseUrl}/docker/${docker_version}/${architectures}/docker-${docker_version}.tgz"
curl -L -o ${save_dir}/etcd/etcd-${etcd_version}-linux-${architectures}.tar.gz "${baseUrl}/etcd/${etcd_version}/${architectures}/etcd-${etcd_version}-linux-${architectures}.tar.gz"
curl -L -o ${save_dir}/containerd/containerd-${containerd_version}-linux-${architectures}.tar.gz "${baseUrl}/containerd/${containerd_version}/${architectures}/containerd-${containerd_version}-linux-${architectures}.tar.gz"
curl -L -o ${save_dir}/helm/helm-${helm_v3_version}-linux-${architectures}.tar.gz "${baseUrl}/helm/${helm_v3_version}/helm-${helm_v3_version}-linux-${architectures}.tar.gz"
curl -L -o ${save_dir}/cni/cni-plugins-linux-${architectures}-${cni_version}.tgz "${baseUrl}/containernetworking/${cni_version}/${architectures}/cni-plugins-linux-${architectures}-${cni_version}.tgz"
curl -L -o ${save_dir}/cni/crictl-${crictl_version}-linux-${architectures}.tar.gz "${baseUrl}/crictl/${crictl_version}/${architectures}/crictl-${crictl_version}-linux-${architectures}.tar.gz"
curl -L -o ${save_dir}/cni/runc.${architectures} "${baseUrl}/runc/${runc_version}/${architectures}/runc.${architectures}"

if [ "$containerd_version" == "1.3.6" ];then
  curl -L -o ${save_dir}/cni/calico-${architectures} "${baseUrl}/cni-plugin/${cni_calico_version}/${architectures}/calico-${architectures}"
  curl -L -o ${save_dir}/cni/calico-ipam-${architectures} "${baseUrl}/cni-plugin/${cni_calico_ipam_version}/${architectures}/calico-ipam-${architectures}"
fi

\cp -rp upload.sh ${save_dir}/
\cp -rp versions/"${k8s_version}.sh" ${save_dir}/

tar zcvf ${k8s_version}_offline.tar.gz ${k8s_version}_offline 1> /dev/null
if [ $? -eq 0 ];then
  echo "Packaged successfully!"
fi