#!/bin/bash

set -ex

[[ "@cross_target_platform@" == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ "@cross_target_platform@" == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ "@cross_target_platform@" == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

CUDA_INCL_DIRS=""
CUDA_LINK_DIRS=""
if [ "${CONDA_BUILD:-0}" = "1" ]; then
    CUDA_INCL_DIRS="${CUDA_INCL_DIRS} -I${PREFIX}/${targetsDir}/include"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${PREFIX}/${targetsDir}/lib"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${PREFIX}/${targetsDir}/lib/stubs"
fi

export CUDA_INCL_DIRS
export CUDA_LINK_DIRS
