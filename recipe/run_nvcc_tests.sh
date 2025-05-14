#!/bin/bash
set -e
set -x

kernel_name="$(uname -s)"
if [[ "${kernel_name}" != "Linux" ]]
then
  echo "Unknown OS. Expected Linux, but found ${kernel_name}"
  exit 1
fi

processor_name="$(uname -m)"
case "${processor_name}" in
  "x86_64") test_platform="linux-64" ;;
  "aarch64") test_platform="linux-aarch64" ;;
  "ppc64le") test_platform="linux-ppc64le" ;;
  *) echo "Unknown architecture: ${processor_name}" && exit 1 ;;
esac

if [[ "${test_platform}" != "${target_platform}" ]]
then
  echo "Skipping NVCC testing as current platform is ${test_platform}, whereas; NVCC is built for ${target_platform}."
  exit 0
fi

cmake_version=$(cmake --version | grep version | awk '{print $3}')

nvcc --version

nvcc --verbose test.cu

cmake -S . -B ./build -G=Ninja && cmake --build ./build -v

if [[ "${target_platform}" == "linux-ppc64le" ]]
then
  echo "Skipping CMake tests on ${target_platform} due to known issues."
  exit 0
fi

mkdir -p cmake-tests
git clone -b v${cmake_version} --depth 1 https://gitlab.kitware.com/cmake/cmake.git cmake-tests
cmake -S cmake-tests -B cmake-tests/build -DCMake_TEST_HOST_CMAKE=ON -DCMake_TEST_CUDA=nvcc -G "Ninja"
cd cmake-tests/build

# Test exclusion list:
# Requires cublas
#   Cuda.ProperDeviceLibraries
#
# Requires curand
#   *SharedRuntime*
#
# Requires execution on a machine with a CUDA GPU
#   Cuda.ObjectLibrary
#   Cuda.WithC
#   Cuda.StubRPATH
#   CudaOnly.ArchSpecial
#   CudaOnly.GPUDebugFlag
#   CudaOnly.SeparateCompilationPTX
#   CudaOnly.WithDefs
#   CudaOnly.CUBIN
#   CudaOnly.Fatbin
#   CudaOnly.OptixIR
#   RunCMake.CUDA_architectures
#   *Toolkit*
# Failing due to undefined symbol: __libc_dl_error_tsd, version GLIBC_PRIVATE
#   Cuda.Complex
CUDAHOSTCXX=$CXX ctest -L CUDA --output-on-failure -j $(nproc) -E "(Architecture|CompileFlags|DeviceLTO|ProperDeviceLibraries|SharedRuntime|ObjectLibrary|WithC|StubRPATH|ArchSpecial|GPUDebugFlag|SeparateCompilationPTX|WithDefs|CUBIN|Fatbin|OptixIR|CUDA_architectures|Toolkit|Cuda.Complex)"
