#!/bin/bash

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

errors=""

for bin in `find ${PREFIX}/bin -type f`; do
    filename=$(basename "${bin}")
    echo "Artifact to test: ${filename}"

    if grep -qx "${filename}" patchelf_exclude.txt; then
	echo Skipping ${filename} as it is not subject to testing
        continue
    fi

    pkg_info=$(conda package -w "${bin}")
    echo "\$PKG_NAME: ${PKG_NAME}"
    echo "\$pkg_info: ${pkg_info}"

    if [[ ! "$pkg_info" == *"$PKG_NAME"* ]]; then
        echo "Not a match, skipping ${bin}"
        continue
    fi

    echo "Match found, testing ${bin}"

    rpath=$(patchelf --print-rpath "${bin}")
    echo "${bin} rpath: ${rpath}"

    if [[ $rpath != "\$ORIGIN/../lib:\$ORIGIN/../${targetsDir}/lib" ]]; then
        errors+="${bin}\n"
    elif [[ $(objdump -x ${bin} | grep "PATH") == *"RUNPATH"* ]]; then
        errors+="${bin}\n"
    fi
done

if [[ $errors ]]; then
    echo "The following binaries were found with an unexpected RPATH:"
    echo -e "${errors}"
    exit 1
fi
