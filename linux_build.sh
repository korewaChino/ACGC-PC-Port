#!/bin/bash
# linux_build.sh - Build the Animal Crossing PC port from source on Linux
#
# SDL2 is built automatically by CMake (FetchContent). No separate SDL step needed.
#
# For a reproducible build, use the Containerfile instead:
#   podman build --no-cache -t acgc-build -f Containerfile .
#
# Prerequisites (Fedora/Ultramarine):
#   sudo dnf install \
#     gcc-c++ cmake make \
#     glibc.i686 glibc-devel.i686 glibc-devel.x86_64 \
#     libstdc++-devel.i686 libstdc++.i686 libgcc.i686 libatomic.i686 \
#     libX11-devel.i686 libXext-devel.i686 libXrandr-devel.i686 \
#     libXcursor-devel.i686 libXi-devel.i686 libXinerama-devel.i686 \
#     libXxf86vm-devel.i686 \
#     alsa-lib-devel.i686 pulseaudio-libs-devel.i686 \
#     mesa-libGL-devel.i686 mesa-libEGL-devel.i686 mesa-dri-drivers.i686 \
#     curl python3
#
# Usage:
#   1. Install the packages above
#   2. python3 configure.py  (downloads N64 SDK headers)
#   3. ./linux_build.sh
#   4. Place disc image in pc/build32/bin/rom/
#   5. cd pc/build32/bin && ./AnimalCrossing --verbose

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/pc/build32"
BIN_DIR="$BUILD_DIR/bin"

# --- CMake configure ---
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -f Makefile ]; then
    echo "=== Configuring CMake for 32-bit Linux ==="
    cmake .. \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_CXX_COMPILER=g++ \
        -DCMAKE_C_FLAGS="-m32" \
        -DCMAKE_CXX_FLAGS="-m32 -isystem /usr/include/c++/16/i686-redhat-linux" \
        -DCMAKE_SKIP_RPATH=ON \
        -DCMAKE_BUILD_TYPE=Release
fi

# --- Build ---
echo "=== Building PC port ==="
make -j"$(nproc)"

# --- Create runtime directories ---
mkdir -p "$BIN_DIR/rom"
mkdir -p "$BIN_DIR/texture_pack"
mkdir -p "$BIN_DIR/save"

echo ""
echo "=== Build complete! ==="
echo ""
echo "Place your Animal Crossing disc image (.ciso/.iso/.gcm) in:"
echo "  pc/build32/bin/rom/"
echo ""
echo "Run:"
echo "  cd pc/build32/bin && ./AnimalCrossing --verbose"
