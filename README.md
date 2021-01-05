# K8SVersionManage

## 摘要
> 此项目主要用于针对KubeOperator自动构建K8S离线包，执行构建的主机需要能够访问互联网。构建完成后，将离线包传到KubeOperator部署机运行即可。
---
## 使用说明
例：打包k8s v1.18.10 版本的离线包 
```
$ bash build.sh v1.18.10
```
> build 完成后，会生成类似 v1.18.10_offline.tar.gz的离线包

登录到KubeOperator部署机上传离线包：
```
$ tar zxvf v1.18.10_offline.tar.gz
$ cd v1.18.10_offline
$ bash upload.sh
# 之后根据提示输入 Nexus 地址，以及用户名和密码
```
