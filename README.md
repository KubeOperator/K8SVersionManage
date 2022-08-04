# KubeOperator 离线包

[KubeOperator](https://github.com/KubeOperator/KubeOperator) 是一个开源的轻量级 Kubernetes 发行版，专注于帮助企业规划、部署和运营生产级别的 K8s 集群。

该项目主要用于针对 [KubeOperator](https://github.com/KubeOperator/KubeOperator) 自动构建 Kubernetes 离线包，执行构建的主机需要能够访问互联网。构建完成后，将离线包传到 [KubeOperator](https://github.com/KubeOperator/KubeOperator) 部署机运行即可。

## 使用说明

例：打包k8s v1.18.10 版本的离线包

```
$ bash build.sh v1.18.10
```

> build 完成后，会生成类似 v1.18.10_offline.tar.gz 的离线包

登录到 [KubeOperator](https://github.com/KubeOperator/KubeOperator) 部署机上传离线包：

```
$ tar zxvf v1.18.10_offline.tar.gz
$ cd v1.18.10_offline
$ bash upload.sh
```

## 问题反馈

如果您在使用过程中遇到什么问题，或有进一步的需求需要反馈，请提交 GitHub Issue 到 [KubeOperator 项目的主仓库](https://github.com/KubeOperator/KubeOperator/issues)
