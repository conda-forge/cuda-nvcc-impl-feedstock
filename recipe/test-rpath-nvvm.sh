#!/bin/bash

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

errors=""

dirs=()
[[ -d ${PREFIX}/nvvm/bin ]] && dirs+=(${PREFIX}/nvvm/bin)
[[ -d ${PREFIX}/nvvm/lib64 ]] && dirs+=(${PREFIX}/nvvm/lib64)

if [[ ${#dirs[@]} == 0 ]]; then
    echo "There is nothing to test. Returning."
    exit
fi

for item in `find ${dirs[@]} -type f`; do
    [[ -L $item ]] && continue

    echo "Artifact to test: ${item}"
    filename=$(basename "${item}")

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
    elif [[ ${item} =~ nvvm/lib64/ && $rpath != "\$ORIGIN" ]]; then
        errors+="${item}\n"
    elif [[ $(objdump -x ${item} | grep "PATH") == *"RUNPATH"* ]]; then
        errors+="${item}\n"
    fi
done

if [[ $errors ]]; then
    echo "The following items were found with an unexpected RPATH:"
    echo -e "${errors}"
    exit 1
fi
