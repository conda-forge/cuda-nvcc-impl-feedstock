#!/bin/bash

set -ex

[[ "@target_platform@" == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ "@target_platform@" == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ "@target_platform@" == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

# For conda-build we add the host requirements prefix to the include and link
# paths because it is separate from the build prefix where nvcc is installed
if [ "${CONDA_BUILD:-0}" = "1" ]; then
    CUDA_INCL_DIRS=""
    CUDA_LINK_DIRS=""
    CUDA_INCL_DIRS="${CUDA_INCL_DIRS} -I${PREFIX}/${targetsDir}/include"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${PREFIX}/${targetsDir}/lib"
    CUDA_LINK_DIRS="${CUDA_LINK_DIRS} -L${PREFIX}/${targetsDir}/lib/stubs"
    export CUDA_INCL_DIRS
    export CUDA_LINK_DIRS
fi

