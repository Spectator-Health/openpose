#! /bin/bash 

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
