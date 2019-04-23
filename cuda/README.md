### cuda s2i images :

#### Setup 
```
CUDA_VERSION=9.0
```

#### Create the templates.
```
oc create -f cuda-build-chain.json
oc create -f cuda-tf-runtime.json
```

#### Create all the cuda images.
```

oc new-app --template=cuda-build-chain  \
--param=S2I_IMAGE=registry.access.redhat.com/rhscl/s2i-core-rhel7:1-56  \
--param=SOURCE_REPOSITORY_CONTEXT_DIR=${CUDA_VERSION} \
--param=APPLICATION_NAME=${CUDA_VERSION}-cuda-chain-rhel7  \
--param=APPLICATION_NAME_1=${CUDA_VERSION}-base-rhel7  \
--param=APPLICATION_NAME_2=${CUDA_VERSION}-runtime-rhel7   \
--param=APPLICATION_NAME_3=${CUDA_VERSION}-cudnn7-runtime-rhel7   \
--param=APPLICATION_NAME_4=${CUDA_VERSION}-devel-rhel7  \
--param=APPLICATION_NAME_5=${CUDA_VERSION}-cudnn7-devel-rhel7 
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

