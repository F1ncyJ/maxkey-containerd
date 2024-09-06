# maxkey-containerd
# 利用K8S节点资源部署Maxkey服务

## 目录结构

```bash
└── docker2containerd （基于MaxKey/docker目录演变而来）
    ├── containerd_nerdctl_install.sh （nerdctl工具安装）
    ├── containerd_nerdctl_uninstall.sh （nerdctl工具卸载）
    ├── docker-compose.yml (待调整，目前无用）
    ├── docker-mysql （Mysql持久化目录）
    ├── docker-nginx （Nginx持久化目录）
    │   ├── Dockerfile
    │   └── default.conf
    ├── maxkey_docker_clear.sh （环境清理）
    ├── maxkey_docker_install.sh （环境安装 | 最先执行）
    ├── maxkey_docker_restart.sh  （容器重启）
    ├── maxkey_docker_rm.sh （容器删除）
    ├── maxkey_docker_start.sh （容器启动）
    └── maxkey_docker_stop.sh （容器停止）
```

## 使用方式

> 前提是在K8S的某个Node节点上，默认是已经安装containerd、ctr等工具的

### step1.工具安装

> 如果已经有nerdctl工具以及CNI环境变量，请跳过

```bash
cd docker2containerd/
sh containerd_nerdctl_install.sh
```

### step2.启动maxkey

```bash
cd docker2containerd/
sh maxkey_docker_install.sh
sh maxkey_docker_start.sh
```



## 卸载方式

### step1.停止maxkey

```bash
cd docker2containerd/
sh maxkey_docker_stop.sh
sh maxkey_docker_rm.sh
maxkey_docker_clear.sh
```

### step2.工具清理

> 仅仅清理本次安装相关的环境变量等，不会影响原有的工具

```bash
cd docker2containerd/
containerd_nerdctl_uninstall.sh
```



---



## 调研记录：

###  k8s、containerd、docker关系

- dockershim：容器引擎管理，底层就是docker，docker操作的是containerd；
- cri-containerd：容器引擎管理，就是containerd，操作的肯定是containerd；
- k8s：
  - (< v1.24): 容器管理（CLI）都基于dockershim;
  - (>= v1.24): 容器管理（CLI）都基于cri-containerd；
- 操作工具：
  - docker：操作docker
  - ctr：操作containerd
  - nerdctl：增强操作containerd，更像docker
  - crictl：基于K8S，在某个节点上，操作固定命名空间(k8s.io)的containerd

[参考-K8S, CRI, OCI, DOCKER, CRI-O之间的关系](https://medium.com/@jgshen/k8s-cri-oci-docker-cri-o之间的关系-82c608a3c4f0)

### 从 k8s 1.24开始 Docker引擎被弃用

[参考-Dockershim Removal](https://kubernetes.io/zh-cn/blog/2022/02/17/dockershim-faq/)

### 相关命令

[Linux Command - Ctr](https://linuxcommandlibrary.com/man/ctr)

[Github/cri-tools - crictl.md](https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md)

[Github/nerdctl commond](https://github.com/containerd/nerdctl/blob/main/docs/command-reference.md)

### containerd各个工具能力对比

| 能力                            | nerdctl（nerdctl）                                           | containerd（ctr）             | crictl（crictl）                         |
| :------------------------------ | :----------------------------------------------------------- | :---------------------------- | :--------------------------------------- |
| 底层                            | 基于containerd的拓展工具                                     | 基于containerd                | 基于K8S（基于container）                 |
| container run                   | 支持                                                         | 支持                          | 支持                                     |
| network                         | 支持                                                         | 不支持                        | 不支持                                   |
| public container port(-p 80:80) | 支持                                                         | 不支持                        | 不支持                                   |
| namespace                       | 支持                                                         | 支持                          | 不支持（自身是基于ctr k8s.io命名空间下） |
| image tag                       | 支持                                                         | 支持                          | 不支持                                   |
| image build                     | 支持                                                         | 不支持                        | 不支持                                   |
| docker login                    | 支持                                                         | 不支持                        | 不支持                                   |
| **用途**                        | **namespace create ****image build****image pull（with login）****image tag****nerwork create****container run****container -p** | **不够全，用nerdctl完全替代** | **不适用**                               |

## 问题记录

### 安装nerdctl工具环境

参考：[git仓库脚本地址](https://git.cai-inc.com/rdc/infra/Infrastructure/idaas/IDaaS-MaxKey/-/blob/zcy/4.1.1/docker2containerd/containerd_nerdctl_install.sh)

安装过程有几个要点：

- 下载github-release包，必须是full版本；解压到自定义目录/opt/nerdctl
- 将 bin/目录命令都关联到 bash_profile中，将CNI工具关联到CNI_PATH环境变量
- 将 `buildkit.service关联到系统中，内置了nerdctl工具目录指向自定义目录/opt/nerdctl`
- `启动buildkit服务`



### 命名空间

期望：利用命名空间做资源隔离，包括网络、镜像、容器等

| 工具            | namespace create                                     | use           |
| :-------------- | :--------------------------------------------------- | :------------ |
| crictl          | 不具备（已经局限于[k8s.io](http://k8s.io/)命名空间） |               |
| containerd(ctr) | 可以                                                 | -n 需要在最前 |
| nerctl          | 可以                                                 | -n 需要在最前 |

当前maxkey启用命名空间【**maxkey.top**】



### 镜像



**拉取方式：**

| 方式    | 示例                             | 原理                                             |        |
| :------ | :------------------------------- | :----------------------------------------------- | :----- |
| crictl  | crictl image pull                | 底层利用containerd镜像拉取，归属k8s.io命名空间下 | 不启用 |
| ctr     | ctr -n maxkey.top image pull     | 就是containerd镜像拉取，支持自定义命名空间       | 可使用 |
| nerdctl | nerdctl -n maxkey.top image pull | 就是containerd镜像拉取，支持自定义命名空间       | 可使用 |



**镜像仓库地址：**

| 镜像名           | docker                             | containerd(ctr)                           | nerctrl                                       |
| :--------------- | :--------------------------------- | :---------------------------------------- | :-------------------------------------------- |
| mysql            | docker image pull mysql            | ctr image pull docker.io/library/mysql    | nerctrl image pull docker.io/library/mysql    |
| nginx            | docker image pull mysql            | ctr image pull docker.io/library/nginx    | nerctrl image pull docker.io/library/nginx    |
| maxkeytop/maxkey | docker image pull maxkeytop/maxkey | ctr image pull docker.io/maxkeytop/maxkey | nerctrl image pull docker.io/maxkeytop/maxkey |

一般都在 docker.io/library/ 目录，部分公司的在自定义分组下例 docker.io/maxkeytop/



**镜像构建：**

使用nerdctl来完成构建，需要安装buildkit



**下载超时：**

Github下载Connection timed out错误，刷新DNS。

```
sudo` `systemctl restart NetworkManager
```



**下载被限制：**

[Docker Hub my-pull-requests-are-being-limited](https://docs.docker.com/docker-hub/download-rate-limit/#how-do-i-know-my-pull-requests-are-being-limited)

错误信息：You have reached your pull rate limit.

解决方式：

1. 利用nerdctl login完成DockerHub账号登录
2. 利用nerdctl image pull拉取镜像会自带登录信息



**镜像拉取超时：**

FATA[0034] failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/58/58e57929741656f03383a01aaa7d9052f029cf74a1e7c806eb56b6c26eeaffbb/data?verify=1724920118-Ej3%2Fm92gB4msLZ8RT2DvDU0qwHg%3D": dial tcp 199.59.148.97:443: i/o timeout

处理：重启buildkit

```
sudo systemctl restart buildkit
```

如果依旧存在问题，那说明IP被dockerHub限流了，只能使用海外节点/服务器



### 容器



**启动过程CNI插件缺失：**

failed to verify networking settings: failed to create default network: needs CNI plugin "bridge" to be installed in CNI_PATH ("/opt/cni/bin"), see https://github.com/containernetworking/plugins/releases: exec: "/opt/cni/bin/bridge": stat /opt/cni/bin/bridge: no such file or directory

```
export CNI_PATH=/opt/nerdctl/libexe/cni
```

cni工具在nerdctl的full版本包中，关联环境变量既可。该过程已包含在安装脚本中。



**网络创建：**

containerd(ctr)没有开放network create命令，可以用nerdctl创建网络。

containerd(ctr)启动容器没有 --network，-p等命令，也可以用nerdctl指定网络并开放端口。
