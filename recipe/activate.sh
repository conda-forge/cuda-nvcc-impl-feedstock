#!/bin/bash

set -ex

[[ "@cross_target_platform@" == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ "@cross_target_platform@" == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ "@cross_target_platform@" == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

CUDA_INCLUDE_DIRS=""
CUDA_LINK_DIRS=""
if [ "${CONDA_BUILD:-0}" = "1" ]; then
    CUDA_INCLUDE_DIRS="${CUDA_INCLUDE_DIRS} -I${PREFIX}/${targetsDir}/include"
    CUDA_INCLUDE_DIRS="${CUDA_INCLUDE_DIRS} -I${BUILD_PREFIX}/${targetsDir}/include"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${PREFIX}/${targetsDir}/lib"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${PREFIX}/${targetsDir}/lib/stubs"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${BUILD_PREFIX}/${targetsDir}/lib"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${BUILD_PREFIX}/${targetsDir}/lib/stubs"
else
    CUDA_INCLUDE_DIRS="${CUDA_INCLUDE_DIRS} -I${CONDA_PREFIX}/${targetsDir}/include"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${CONDA_PREFIX}/${targetsDir}/lib"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${CONDA_PREFIX}/${targetsDir}/lib/stubs"
fi

export CUDA_INCLUDE_DIRS
export CUDA_LINK_DIRS
