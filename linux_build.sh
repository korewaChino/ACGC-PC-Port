#!/bin/bash
# linux_build.sh - Build the Animal Crossing PC port on Linux
#
# Prerequisites (Fedora/Ultramarine):
#   sudo dnf install \
#     gcc-c++.i686 \
#     glibc-devel.i686 \
#     libstdc++-devel.i686 \
#     mesa-libGL-devel.i686 \
#     sdl2-compat-devel.i686 \
#     libX11-devel.i686 libXext-devel.i686 \
#     libXrandr-devel.i686 libXcursor-devel.i686 \
#     libXi-devel.i686 libXinerama-devel.i686
#
# Usage:
#   1. sudo dnf install <packages above>
#   2. ./linux_build.sh
#   3. Place your disc image (.ciso/.iso/.gcm) in pc/build32/bin/rom/
#   4. cd pc/build32/bin && LD_LIBRARY_PATH=. ./AnimalCrossing

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
        -DCMAKE_C_FLAGS="-m32 -fno-use-linker-plugin" \
        -DCMAKE_CXX_FLAGS="-m32 -fno-use-linker-plugin" \
        -DCMAKE_SKIP_RPATH=ON \
        -DCMAKE_EXE_LINKER_FLAGS="-fno-use-linker-plugin"
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
echo "  cd pc/build32/bin && LD_LIBRARY_PATH=. ./AnimalCrossing"