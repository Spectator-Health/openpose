#!/bin/bash

# cuDNN version info include file 
_CUDNN_VERSION_FILE='s/cudnn_version.h/cudnn.h/g' 
#_CUDNN_VERSION_FILE='s/cuddn.h/cuddn_version.h/g'  # cuDNN >= 8.0 

echo "------------------------- Installing Caffe and OpenPose -------------------------"
echo "NOTE: This script assumes that just flashed JetPack 4.3 Ubuntu 18.04, CUDA 10.2, cuDNN 7  and OpenCV are already installed on your machine. Otherwise, it might fail."
echo "NOTE: Until Caffe is updated, Jetpack 4.4 (with cuDNN >= 8) is not supported." 
# Ref: https://spyjetson.blogspot.com/2019/10/  *See "Install OpenPose for JetPack 4.4 (Developer Preview) 


function exitIfError {
    if [[ $? -ne 0 ]] ; then
        echo ""
        echo "------------------------- -------------------------"
        echo "Errors detected. Exiting script. The software might have not been successfully installed."
        echo "------------------------- -------------------------"
        exit 1
    fi
}

# Install OpenPose dependencies 
./scripts/ubuntu/install_deps.sh
exitIfError 

# Configure Makefile using CMake (must be >= 3.12) TODO: Write CMake version check 
# Ref: https://kezunlin.me/post/8e6eb7bb/  * See "upgrade cmake" 
mkdir build 
cd build 
sudo cmake \
	-DCMAKE_INSTALL_PREFIX=/usr/local \
	-DCUDA_HOST_COMPILER=/usr/bin/cc \
	-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
	-DCUDA_USE_STATIC_CUDA_RUNTIME=ON \
	-DCUDA_rt_LIBRARY=/usr/lib/aarch64-linux-gnu/librt.so \
	-DCUDA_ARCH_BIN=7.2 \
	-DGPU_MODE=CUDA \
	-DDOWNLOAD_COCO_MODEL=ON \
	-DUSE_OPENCV=ON \
	-DBUILD_PYTHON=ON \
	-DBUILD_EXAMPLES=ON \
	-DBUILD_DOCS=OFF \
	-DBUILD_CAFFE=ON .. 

sed -i -e ${_CUDNN_VERSION_FILE} ../3rdparty/caffe/cmake/Cuda.cmake 
# Run make 
sudo make -j`nproc` 
sudo make install 

echo "------------------------- Caffe and OpenPose Installed -------------------------"
echo ""

# Python build 
# NOTE: Don't do make install command b/c it installs openpose module to Python 2.7 directory 
# If you run `make` (default path is `/usr/local/python` for Ubuntu), you can also access the OpenPose/python module from there. This will install OpenPose and the python library at your desired installation path. Ensure that this is in your python path in order to use it.
cd python 
make -j`nproc`

echo "------------------------- Python Modules Installed -------------------------"
echo ""

cd ../.. 

