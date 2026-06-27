# Build container for Animal Crossing PC port (32-bit)
FROM fedora:43

# Build-time Mesa (26.1.3 from updates is fine for headers; the broken
# 32-bit LLVM is only a runtime concern on the host)
RUN dnf install -y \
    gcc gcc-c++ cmake make \
    glibc.i686 glibc-devel.i686 glibc-devel.x86_64 \
    libstdc++-devel.i686 libstdc++.i686 libgcc.i686 \
    libatomic.i686 \
    libX11-devel.i686 libXext-devel.i686 libXrandr-devel.i686 \
    libXcursor-devel.i686 libXi-devel.i686 libXinerama-devel.i686 \
    libXxf86vm-devel.i686 \
    alsa-lib-devel.i686 pulseaudio-libs-devel.i686 \
    mesa-libGL-devel.i686 mesa-libEGL-devel.i686 mesa-dri-drivers.i686 \
    curl && \
    echo 'Testing 32-bit C compile...' && \
    echo 'int main(){return 0;}' | gcc -m32 -x c - -o /tmp/test32 && \
    /tmp/test32 && echo '32-bit works!' && \
    dnf clean all

# Copy project and set up N64 SDK headers
COPY . /build/project
RUN cd /build/project && python3 configure.py && \
    echo 'configure.py complete'

WORKDIR /build/project/pc

# SDL2 is built automatically by CMake (FetchContent).
# Fedora 44's GCC x86_64 driver with -m32 doesn't add the 32-bit C++ include
# directory automatically. Add it via CMAKE_CXX_FLAGS.
RUN rm -rf build32 && mkdir -p build32 && cd build32 && \
    cmake .. \
        -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
        -DCMAKE_C_FLAGS="-m32" \
        -DCMAKE_CXX_FLAGS="-m32 -isystem /usr/include/c++/16/i686-redhat-linux" \
        -DCMAKE_SKIP_RPATH=ON \
        -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)
