#!/usr/bin/env bash

architectures=amd64
k8s_version=v1.18.12
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
read -p "请输入仓库地址：" registry_ip
read -p "请输入仓库登录用户名：" registry_user
echo "请输入仓库登录密码："
read -s registry_password


case "$k8s_version" in
  v1.18.4) source v1.18.4.sh ;;
  v1.18.6) source v1.18.6.sh ;;
  v1.18.8) source v1.18.8.sh ;;
  v1.18.10) source v1.18.10.sh ;;
  v1.18.12) source v1.18.12.sh ;;
esac

if curl -k -X GET --user "${registry_user}:${registry_password}" "http://${registry_ip}:8081/service/rest/beta/security/user-sources" -H "accept: application/json" 1> /dev/null;then
  echo "Nexus login successfully!"
  echo "****************************"
  sleep 2
else
  echo "Nexus login failed!"
  exit 0
fi

if docker login ${registry_ip}:8083 -u${registry_user} -p${registry_password};then
  echo "Docker login successfully!"
  echo "****************************"
  sleep 2
else
  echo "Docker login failed!"
  exit 0
fi

base_url=http://${registry_ip}:8081/repository/binary-k8s-raw
# 上传k8s_raw
for f in k8s/*
do
  f_name=`echo $f|sed -r 's/.*\///'`
  echo "Upload ${f_name}"
  case $f in
  *.tar)
    echo "Job: k8s_raw ${f}"
    curl -k -v --user "${registry_user}:${registry_password}" --upload-file ${f} ${base_url}/k8s/${k8s_version}/${architectures}/${f_name}
    echo "----------------------------"
    ;;
  *.gz) c
    echo "Job: k8s_raw ${f}"
    url -k -v --user "${registry_user}:${registry_password}" --upload-file ${f} ${base_url}/k8s/${k8s_version}/${architectures}/${f_name}
    echo "----------------------------"
    ;;
  esac
done


# 上传组建二进制文件
curl -k -v --user "${registry_user}:${registry_password}" --upload-file docker/docker-${docker_version}.tgz  ${base_url}/docker/${docker_version}/${architectures}/docker-${docker_version}.tgz
curl -k -v --user "${registry_user}:${registry_password}" --upload-file etcd/etcd-${etcd_version}-linux-${architectures}.tar.gz  ${base_url}/etcd/${etcd_version}/${architectures}/etcd-${etcd_version}-linux-${architectures}.tar.gz
curl -k -v --user "${registry_user}:${registry_password}" --upload-file containerd/containerd-${containerd_version}-linux-${architectures}.tar.gz  ${base_url}/containerd/${containerd_version}/${architectures}/containerd-${containerd_version}-linux-${architectures}.tar.gz
curl -k -v --user "${registry_user}:${registry_password}" --upload-file helm/helm-${helm_v3_version}-linux-${architectures}.tar.gz  ${base_url}/helm/${helm_v3_version}/helm-${helm_v3_version}-linux-${architectures}.tar.gz

if [ "$architectures" == "amd64" ];then
    curl -k -v --user "${registry_user}:${registry_password}" --upload-file  helm/helm-${helm_v2_version}-linux-${architectures}.tar.gz ${base_url}/helm/${helm_v2_version}/helm-${helm_v2_version}-linux-${architectures}.tar.gz
fi

for image in images/*.tar; do
    echo "Job: Docker push ${image} ==>"
    orign_image_name=`docker load -i $image|awk '{print $3}'`
    if [[ ${image_name} =~ "quay.io" ]]; then
      image_name=`echo ${orign_image_name}|sed -r 's/quay.io\///g'`
    else
      image_name=${orign_image_name}
    fi
    docker tag ${orign_image_name} ${registry_ip}:8083/${image_name}
    docker push ${registry_ip}:8083/${image_name}
#    清理docker镜像
    docker rmi ${orign_image_name}
    docker rmi ${registry_ip}:8083/${image_name}
    echo "----------------------------"
done


if [ $? -eq 0 ];then
  echo "${k8s_version} Upload finished!"
else
  echo "${k8s_version} Upload Failed!"
fi
