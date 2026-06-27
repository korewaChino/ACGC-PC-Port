# Build container for Animal Crossing PC port (64-bit)
FROM fedora:44

RUN dnf install -y \
    gcc gcc-c++ cmake make \
    glibc-devel libstdc++-devel libgcc libatomic \
    libX11-devel libXext-devel libXrandr-devel \
    libXcursor-devel libXi-devel libXinerama-devel \
    libXxf86vm-devel \
    alsa-lib-devel pulseaudio-libs-devel \
    sdl2-compat-devel mesa-libGL-devel mesa-libEGL-devel mesa-dri-drivers \
    curl python3 && \
    echo 'Testing 64-bit C compile...' && \
    echo 'int main(){return 0;}' | gcc -x c - -o /tmp/test64 && \
    /tmp/test64 && echo '64-bit works!' && \
    dnf clean all

# Copy project and set up N64 SDK headers
COPY . /build/project
RUN cd /build/project && python3 configure.py && \
    echo 'configure.py complete'

WORKDIR /build/project/pc

RUN rm -rf build && mkdir -p build && cd build && \
    cmake .. && \
    make -j$(nproc)
