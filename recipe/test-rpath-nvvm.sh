#!/bin/bash

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

errors=""

for item in `find ${PREFIX}/nvvm/bin -type f`; do
    filename=$(basename "${item}")
    echo "Artifact to test: ${filename}"

    pkg_info=$(conda package -w "${item}")
    echo "\$PKG_NAME: ${PKG_NAME}"
    echo "\$pkg_info: ${pkg_info}"

    if [[ ! "$pkg_info" == *"$PKG_NAME"* ]]; then
        echo "Not a match, skipping ${item}"
        continue
    fi

    echo "Match found, testing ${item}"

    rpath=$(patchelf --print-rpath "${item}")
    echo "${item} rpath: ${rpath}"

    if [[ ${item} =~ /nvvm/bin/ && $rpath != "\$ORIGIN/../lib64:\$ORIGIN/../../lib:\$ORIGIN/../../${targetsDir}/lib" ]]; then
        errors+="${item}\n"
    # lib64/libnvvm.so patching is being skipped so let's not test it
    #elif [[ ${item} =~ nvvm/lib64/ && $rpath != "\$ORIGIN" ]]; then
    #    errors+="${item}\n"
    elif [[ $(objdump -x ${item} | grep "PATH") == *"RUNPATH"* ]]; then
        errors+="${item}\n"
    fi
done

if [[ $errors ]]; then
    echo "The following items were found with an unexpected RPATH:"
    echo -e "${errors}"
    exit 1
fi
