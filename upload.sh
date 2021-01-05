#!/usr/bin/env bash

architectures=amd64
k8s_version=v1.18.14

read -p "请输入仓库地址：" registry_ip
if echo $registry_ip|grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}";then
  read -p "请输入仓库登录用户名：" registry_user
  echo "请输入仓库登录密码："
  read -s registry_password
else
  echo "IP地址错误"
  exit 0
fi

if curl -k -X GET --user "${registry_user:}:${registry_password}" "https://${registry_ip}:8081/service/rest/beta/security/user-sources" -H "accept: application/json" 1> /dev/null;then
  echo "Nexus login successfully!"
  echo "****************************"
else
  echo "Nexus login failed!"
  exit 0
fi

base_url=http://${registry_ip}:8081/repository/binary-k8s-raw/k8s
for f in *
do
  case $f in
  *.tar) curl -k -v --user "${registry_user}:${registry_password}" --upload-file ${f} ${base_url}/${k8s_version}/${architectures}/${f};;
  *.gz) curl -k -v --user "${registry_user}:${registry_password}" --upload-file ${f} ${base_url}/${k8s_version}/${architectures}/${f};;
  esac
done

echo "****************************"
if [ $? -eq 0 ];then
  echo "${k8s_version} Upload successfully!"
else
  echo "${k8s_version} Upload Failed!"
fi
