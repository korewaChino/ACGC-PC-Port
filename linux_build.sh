#!/bin/bash
# linux_build.sh - Build the Animal Crossing PC port from source on Linux
#
# Default: 32-bit build in pc/build32 using vendored static SDL2.
# Optional: 64-bit experimental build in pc/build64.
#
# For a reproducible 32-bit container build, use the Containerfile instead:
#   podman build --no-cache -t acgc-build -f Containerfile .
#
# Prerequisites (Fedora/Ultramarine, 32-bit default build):
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
# Additional/alternate packages for 64-bit or system SDL2 experiments:
#   sudo dnf install SDL2-devel sdl2-compat-devel mesa-libGLU-devel
#
# Usage:
#   1. python3 configure.py  (downloads N64 SDK headers)
#   2. ./linux_build.sh [--32|--64] [--pie] [--system-sdl2] [--clean]
#   3. Place disc image in pc/build32/bin/rom/ or pc/build64/bin/rom/
#   4. cd pc/buildXX/bin && ./AnimalCrossing --verbose

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCH="32"
PC_PIE="OFF"
PC_SYSTEM_SDL2="OFF"
CLEAN="0"

usage() {
    cat <<EOF
Usage: ./linux_build.sh [options]

Options:
  --32             Build 32-bit Linux binary in pc/build32 (default)
  --64             Build experimental 64-bit Linux binary in pc/build64
  --pie            Enable PC_PIE=ON (-fPIE/-pie; vendored SDL2 built with PIC)
  --system-sdl2    Enable PC_SYSTEM_SDL2=ON (system SDL2/sdl2-compat)
  --clean          Remove selected build directory before configuring
  -h, --help       Show this help

Examples:
  ./linux_build.sh
  ./linux_build.sh --64
  ./linux_build.sh --64 --system-sdl2
  ./linux_build.sh --64 --pie --system-sdl2 --clean
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --32)
            ARCH="32"
            ;;
        --64)
            ARCH="64"
            ;;
        --pie)
            PC_PIE="ON"
            ;;
        --system-sdl2)
            PC_SYSTEM_SDL2="ON"
            ;;
        --clean)
            CLEAN="1"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

BUILD_DIR="$SCRIPT_DIR/pc/build${ARCH}"
BIN_DIR="$BUILD_DIR/bin"

if [ "$CLEAN" = "1" ]; then
    echo "=== Removing $BUILD_DIR ==="
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# --- CMake configure ---
if [ "$ARCH" = "32" ]; then
    echo "=== Configuring CMake for 32-bit Linux ==="
    cmake .. \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_CXX_COMPILER=g++ \
        -DCMAKE_C_FLAGS="-m32" \
        -DCMAKE_CXX_FLAGS="-m32 -isystem /usr/include/c++/$(g++ -dumpversion)/i686-redhat-linux" \
        -DPC_PIE="$PC_PIE" \
        -DPC_SYSTEM_SDL2="$PC_SYSTEM_SDL2" \
        -DCMAKE_SKIP_RPATH=ON \
        -DCMAKE_BUILD_TYPE=Release
else
    echo "=== Configuring CMake for 64-bit Linux (experimental) ==="
    cmake .. \
        -DPC_64BIT=ON \
        -DPC_PIE="$PC_PIE" \
        -DPC_SYSTEM_SDL2="$PC_SYSTEM_SDL2" \
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
echo "Build directory: pc/build${ARCH}"
echo "Binary:          pc/build${ARCH}/bin/AnimalCrossing"
echo ""
echo "Place your Animal Crossing disc image (.ciso/.iso/.gcm) in:"
echo "  pc/build${ARCH}/bin/rom/"
echo ""
echo "Run:"
echo "  cd pc/build${ARCH}/bin && ./AnimalCrossing --verbose"
