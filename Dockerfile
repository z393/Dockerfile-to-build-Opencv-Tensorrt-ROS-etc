FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
ARG TENSORRT_VERSION=5.0.2.6
ARG PY3_VERSION=3.6
ARG OPENCV_VERSION=3.3.1
RUN mv /etc/apt/sources.list /etc/apt/sourses.list.backup
ADD sources.list /etc/apt/
# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        autoconf \
        automake \
        libtool \
        pkg-config \
        ca-certificates \
        wget \
        git \
        vim \
        unzip \
        python \
        python-dev \
        python-pip \
        python-numpy \
        python-setuptools \
        python3 \
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-setuptools \
        libprotobuf-dev \
        protobuf-compiler \
        cmake \
        swig \
        libgtk2.0-dev \
        pkg-config \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libdc1394-22-dev \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        libavcodec-dev \ 
        libavformat-dev \
        libswscale-dev \ 
        libavutil-dev \
        libavresample-dev \
        libxvidcore-dev \
        libx264-dev \
        libv4l-dev \
        software-properties-common \
        libjasper-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/yolo-tensorrt

COPY . .

# Install cudnn
RUN tar -xvf cudnn-10.0-v7-3-1.tar.gz && \
    cp cuda/include/cudnn.h /usr/local/cuda/include/ && \
    cp cuda/lib64/libcudnn* /usr/local/cuda/lib64/ && \
    chmod a+r /usr/local/cuda/include/cudnn.h && \
    chmod a+r /usr/local/cuda/lib64/libcudnn* && \
    rm -rf cudnn-10.0-v7-3-1.tar.gz
	
# opencv ldconfig时报错，执行此句    
RUN ln -sf /usr/local/cuda-10.0/lib64/libcudnn.so.7.3.1 /usr/local/cuda-10.0/lib64/libcudnn.so.7 

# Install opencv
RUN unzip opencv-${OPENCV_VERSION}.zip && \
    cd opencv-${OPENCV_VERSION}/ && \
    mkdir -p build && \
    cd build && \
    cmake -D CMAKE_INSTALL_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local/ .. && \
    make -j$(nproc) && \
    make install && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf && \
    ldconfig && \
    cd ../../ && \
    rm -r opencv-${OPENCV_VERSION}.zip 
      
	
# Install TensorRT
RUN tar -xvf TensorRT-${TENSORRT_VERSION}.*.tar.gz && \
    cd TensorRT-${TENSORRT_VERSION}/ && \
    cp lib/lib* /usr/lib/ && \
    cp include/* /usr/include/ && \
    cp bin/* /usr/bin/ && \
    pip3 install python/tensorrt-${TENSORRT_VERSION}-py2.py3-none-any.whl && \
    pip3 install uff/uff-*-py2.py3-none-any.whl && \
    pip3 install graphsurgeon/graphsurgeon-*-py2.py3-none-any.whl && \
    cd ../ && \
    rm -rf TensorRT-${TENSORRT_VERSION}.*.tar.gz 
   
	
# Install ROS
ENV DEBIAN_FRONTEND=noninteractive
ADD 20-default.list /etc/ros/rosdep/sources.list.d/
RUN . /etc/lsb-release && echo "deb http://mirrors.ustc.edu.cn/ros/ubuntu/ $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/ros-latest.list
RUN gpg --keyserver keyserver.ubuntu.com --recv F42ED6FBAB17C654 && \
    gpg --export --armor F42ED6FBAB17C654 | apt-key add - && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

RUN apt-get update && apt-get install -y ros-melodic-desktop-full --allow-unauthenticated  
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    terminator \    
    python-vcstools \ 
  && rm -rf /var/lib/apt/lists/* 
RUN rm /etc/ros/rosdep/sources.list.d/20-default.list
RUN rosdep init && \ 
    rosdep update && \
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && \
    /bin/bash -c "source ~/.bashrc" 

# 
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        autoconf \
        automake \
        autopoint \
        libglib2.0-dev \
        libtool \
        openjdk-8-jdk \
        python-dev\
    && rm -rf /var/lib/apt/lists/*

# Install lcm
RUN unzip lcm-${LCM_VERSION}.zip && \
    cd lcm-${LCM_VERSION} && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd /usr/local/lib && \
    ldconfig && \
	rm -rf lcm-${LCM_VERSION}.zip 

# Install glog
RUN unzip glog-master.zip && \
   cd glog-master && \
   ./configure && \
   make -j$(nproc) && \
   make install && \
   cd /usr/local/lib && \
   ldconfig && \
   rm -rf glog-master.zip 
   
# install libLanelet
RUN apt-get update && apt-get install -y --no-install-recommends \
           libboost-dev \ 
           scons \
           && unzip liblanelet-master.zip && \
           cd liblanelet-master/libLanelet/build && \
           cp libLanelet.so /usr/local/lib && \
           cd ../../../liblanelet-master/libpugixml/build && \
           cp libpugixml.so /usr/local/lib && \
           cd ../../../liblanelet-master/googletest/build && \
           cd /usr/local/lib && \
           ldconfig && \
		   rm -rf liblanelet-master.zip
		   
# install libsodium
RUN tar -xzvf libsodium-1.0.3.tar.gz && \
    cd libsodium-1.0.3 && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd /usr/local/lib && \
    cp libsodium* /usr/lib  &&\
	rm -rf libsodium-1.0.3.tar.gz
	
# install zeromq
RUN tar -xzvf zeromq-4.1.5.tar.gz && \
    cd zeromq-4.1.5 && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd /usr/local/lib && \
    ldconfig && \
	rm -rf zeromq-4.1.5.tar.gz
   
#install openGL
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1-mesa-dev  \
        libglu1-mesa-dev  \
        freeglut3-dev 

#install  "build boost"
RUN apt-get update && apt-get install -y aptitude && \
    aptitude install -y libboost-filesystem1.65-dev \ 
    libboost-system1.65-dev \
	
RUN ["/bin/bash"]

