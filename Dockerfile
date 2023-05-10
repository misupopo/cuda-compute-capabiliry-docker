FROM nvcr.io/nvidia/deepstream-l4t:6.2-base

# Install Dependencies
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    g++ \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgtk-3-dev \
    libssl-dev \
    libgtk-3-dev \
    libcurl4-openssl-dev \
    python-pip \
    python3-pip \
    python3-dev \
    tzdata \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/python-cv2
WORKDIR /tmp/python-cv2

ADD . .
RUN pip3 install --upgrade pip \
 && pip3 install -r ./requirements.txt

# Install UVC Driver Gstreamer
RUN apt-get update && apt-get install -y \
    uvccapture \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-doc \
    gstreamer1.0-tools \
    python-gst-1.0 \
    python3-gst-1.0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install OPENCV 4.1.2 With CUDA
# CUDA_COMPUTE_CAPABILITY => JETSON AGX XAVIER = 7.2, JETSON NANO = 5.3, JETSON TX2 = 6.2
ENV CUDA_COMPUTE_CAPABILITY "7.2"
RUN git clone https://github.com/opencv/opencv.git -b 4.1.2 \
    && git clone https://github.com/opencv/opencv_contrib -b 4.1.2 \
    && mkdir /tmp/python-cv2/opencv/build \
    && cd /tmp/python-cv2/opencv/build \
    && cmake \
       -D CMAKE_BUILD_TYPE=RELEASE \
       -D CMAKE_INSTALL_PREFIX=/usr/local \
       -D WITH_CUDA=ON \
       -D CUDA_ARCH_BIN= ${CUDA_COMPUTE_CAPABILITY} \
       -D CUDA_ARCH_PTX="" \
       -D WITH_CUBLAS=ON \
       -D ENABLE_FAST_MATH=ON \
       -D CUDA_FAST_MATH=ON \
       -D ENABLE_NEON=ON \
       -D WITH_LIBV4L=ON \
       -D BUILD_TESTS=OFF \
       -D BUILD_PERF_TESTS=OFF \
       -D BUILD_EXAMPLES=OFF \
       -D WITH_QT=OFF \
       -D WITH_OPENGL=ON \
       -D BUILD_opencv_xfeatures2d=OFF \
       -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
       -D BUILD_opencv_cudaoptflow=OFF ..\
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/python-cv2/opencv /tmp/python-cv2/opencv_contrib \
    && ldconfig

CMD ["/bin/bash"]

