#!/bin/bash



echo "------------------------- Installing Caffe and OpenPose -------------------------"
echo "NOTE: This script assumes that just flashed JetPack 4.4: Ubuntu 18.04, CUDA 10.2, cuDNN 8.0 and OpenCV are already installed on your machine. Otherwise, it might fail."



function exitIfError {
    if [[ $? -ne 0 ]] ; then
        echo ""
        echo "------------------------- -------------------------"
        echo "Errors detected. Exiting script. The software might have not been successfully installed."
        echo "------------------------- -------------------------"
        exit 1
    fi
}



function executeShInItsFolder {
    # $1 = sh file name
    # $2 = folder where the sh file is
    # $3 = folder to go back
    cd $2
    exitIfError
    sudo chmod +x $1
    exitIfError
    bash ./$1
    exitIfError
    cd $3
    exitIfError
}



rm -rf ./3rdparty/caffe && mkdir ./3rdparty/caffe
git submodule update --init --recursive --remote
#executeShInItsFolder "install_caffe_JetsonAGX_JetPack4.4.sh" "./3rdparty/caffe" "../.."
executeShInItsFolder "install_caffe_JetsonTX2_JetPack3.3.sh" "./3rdparty/caffe" "../.."
exitIfError



executeShInItsFolder "./scripts/ubuntu/install_openpose_JetsonAGX_JetPack4.4.sh" "./" "./"
exitIfError



echo "------------------------- Caffe and OpenPose Installed -------------------------"
echo ""
