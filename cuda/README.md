### cuda s2i images :

#### Setup 
```
CUDA_VERSION=10.0
OS_VERSION=rhel7
S2I_PYTHON_VERSION=3.6
```

#### Create the templates.
```
oc create -f cuda-build-chain.json
oc create -f cuda-tf-runtime.json
```

#### Create all the cuda images.
The values for `S2I_IMAGE` are :
https://access.redhat.com/containers/#/search/s2i  
https://registry.fedoraproject.org/repo/f28/s2i-base/tags/  

registry.access.redhat.com/rhscl/s2i-base-rhel7  
registry.access.redhat.com/rhel8/s2i-base  
registry.access.redhat.com/ubi7/s2i-base  
registry.access.redhat.com/ubi8/s2i-base  
registry.access.redhat.com/f28/s2i-base  
registry.fedoraproject.org/f27/s2i-base  
```

oc new-app --template=cuda-build-chain  \
--param=S2I_IMAGE=registry.access.redhat.com/rhscl/s2i-base-rhel7:latest  \
--param=SOURCE_REPOSITORY_CONTEXT_DIR=${CUDA_VERSION} \
--param=S2I_PYTHON_VERSION=${S2I_PYTHON_VERSION} \
--param=APPLICATION_NAME=${CUDA_VERSION}-cuda-chain-${OS_VERSION}  \
--param=APPLICATION_NAME_1=${CUDA_VERSION}-base-${OS_VERSION}  \
--param=APPLICATION_NAME_2=${CUDA_VERSION}-runtime-${OS_VERSION}   \
--param=APPLICATION_NAME_3=${CUDA_VERSION}-cudnn7-runtime-${OS_VERSION}   \
--param=APPLICATION_NAME_4=${CUDA_VERSION}-devel-${OS_VERSION}  \
--param=APPLICATION_NAME_5=${CUDA_VERSION}-cudnn7-devel-${OS_VERSION} \
--param=APPLICATION_NAME_6=python-36-${OS_VERSION} 
```

```

oc new-app --template=cuda-tf-runtime  \
--param=S2I_BASE_IMAGE=cuda:10.0-cudnn7-devel-rhel7  \
--param=DOCKER_FILE_PATH=Dockerfile.centos7 \
--param=PYTHON_VERSION=2.7 \
--param=TF_PACKAGE=

oc new-app --template=cuda-tf-runtime  \
--param=S2I_BASE_IMAGE=cuda:10.0-cudnn7-devel-rhel7  \
--param=APPLICATION_NAME=cuda-tf-runtime-36-redhat \
--param=APPLICATION_IMAGE_TAG=rhel7-1-56-10.0-cudnn7-devel-rhel7 \
--param=DOCKER_FILE_PATH=Dockerfile.centos7 \
--param=PYTHON_VERSION=3.6 \
--param=TF_PACKAGE=https://github.com/AICoE/tensorflow-wheels/releases/download/tf-r1.13-cpu-2019-04-23_015354/tensorflow-1.13.1-cp36-cp36m-linux_x86_64.whl

```
get `TF_PACKAGE` values from [AICoE/tensorflow-wheels](https://github.com/AICoE/tensorflow-wheels/releases).

#### To delete all resources
```
oc delete  all -l appTypes=cuda-build-chain
oc delete  all -l appName=${CUDA_VERSION}-cuda-chain-rhel7

```


```
INTERNAL_REGISTRY=docker-registry.engineering.redhat.com/aicoe
docker tag docker-registry.default.svc:5000/test/cuda:10.0-base-rhel7 ${INTERNAL_REGISTRY}/cuda:10.0-base-rhel7
docker tag docker-registry.default.svc:5000/test/cuda:10.0-runtime-rhel7 ${INTERNAL_REGISTRY}/cuda:10.0-runtime-rhel7
docker tag docker-registry.default.svc:5000/test/cuda:10.0-cudnn7-runtime-rhel7 ${INTERNAL_REGISTRY}/cuda:10.0-cudnn7-runtime-rhel7
docker tag docker-registry.default.svc:5000/test/cuda:10.0-devel-rhel7 ${INTERNAL_REGISTRY}/cuda:10.0-devel-rhel7
docker tag docker-registry.default.svc:5000/test/cuda:10.0-cudnn7-devel-rhel7 ${INTERNAL_REGISTRY}/cuda:10.0-cudnn7-devel-rhel7
docker tag docker-registry.default.svc:5000/test/python-36-rhel7:10.0-cudnn7-devel-rhel7  ${INTERNAL_REGISTRY}/python-36-rhel7:10.0-cudnn7-devel-rhel7

sudo docker push ${INTERNAL_REGISTRY}/cuda:10.0-base-rhel7
sudo docker push ${INTERNAL_REGISTRY}/cuda:10.0-runtime-rhel7
sudo docker push ${INTERNAL_REGISTRY}/cuda:10.0-cudnn7-runtime-rhel7
sudo docker push ${INTERNAL_REGISTRY}/cuda:10.0-devel-rhel7
sudo docker push ${INTERNAL_REGISTRY}/cuda:10.0-cudnn7-devel-rhel7
sudo docker push ${INTERNAL_REGISTRY}/python-36-rhel7:10.0-cudnn7-devel-rhel7
```