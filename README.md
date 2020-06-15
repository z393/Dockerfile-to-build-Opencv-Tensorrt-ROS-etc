# Dockerfile-to-build-Opencv-Tensorrt-ROS-etc
### This project is to build the image of Cudnn7.3.1, Tensorrt5.0.2.6, Opencv3.3.1, ros,　lcm , etc under the base image of ubuntu18.04 and Cuda10.0.
1. pull image　

```sudo docker pull nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04```

2. download the installation package

   [cudnn](https://developer.nvidia.com/rdp/cudnn-archive) 
   
   [opencv](https://opencv.org/releases/page/4/)
   
   [tensorrt](https://developer.nvidia.com/nvidia-tensorrt-download)
   
   [lcm](https://developer.nvidia.com/nvidia-tensorrt-download)
   
   ...
   
   put the installation package in this directory
   
 3. build image
 
 ```sudo docker build -f Dockerfile -t xavier:version-v1 .```
 
  note : xavier:version-v1 is the name and tag of the new image, you can replace it.
