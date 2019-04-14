### cuda s2i images :

#### Setup 
```
CUDA_VERSION=9.0
```

#### Create the templates.
```
oc create -f cuda-build-chain.json
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

#### To delete all resources
```
oc delete  all -l appTypes=cuda-build-chain
oc delete  all -l appName=${CUDA_VERSION}-cuda-chain-rhel7

```

