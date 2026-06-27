# Animal Crossing PC Port (now GCC compatible!)

A native PC port of Animal Crossing (GameCube) built on top of the [ac-decomp](https://github.com/ACreTeam/ac-decomp) decompilation project.

The game's original C code runs natively on x86, with a custom translation layer replacing the GameCube's GX graphics API with OpenGL 3.3.

This repository does not contain any game assets or assembly whatsoever. An existing copy of the game is required.

Supported versions: GAFE01_00: Rev 0 (USA)

## Quick Start (Pre-built Release)

Pre-built releases are available on the [Releases](https://github.com/flyngmt/ACGC-PC-Port/releases) page. No build tools required.

1. Download and extract the latest release zip
2. Place your disc image in the `rom/` folder
3. Run `AnimalCrossing.exe`

The game reads all assets directly from the disc image at startup. No extraction or preprocessing step is needed.

## Building from Source

Only needed if you want to modify the code. Otherwise, use the [pre-built release](https://github.com/flyngmt/ACGC-PC-Port/releases) above.

### 🐧 Linux

Run the setup step once after cloning:

```bash
python3 configure.py
```

The Linux build supports both the original 32-bit target and an experimental 64-bit target.

#### 32-bit build

The 32-bit build is the default supported Linux target. It uses `-m32` and builds a vendored static SDL2 by default.

```bash
rm -rf pc/build32
mkdir -p pc/build32
cd pc/build32
cmake .. \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DCMAKE_C_FLAGS="-m32" \
  -DCMAKE_CXX_FLAGS="-m32 -isystem /usr/include/c++/$(g++ -dumpversion)/i686-redhat-linux" \
  -DCMAKE_SKIP_RPATH=ON \
  -DCMAKE_BUILD_TYPE=Release
make -j"$(nproc)"
```

Output:

```text
pc/build32/bin/AnimalCrossing
```

#### 64-bit build experimental

The 64-bit build avoids the 32-bit toolchain and multilib runtime, but it is still experimental. Some pointer-to-`u32` assumptions remain under active porting work.

```bash
rm -rf pc/build64
mkdir -p pc/build64
cd pc/build64
cmake .. \
  -DPC_64BIT=ON \
  -DCMAKE_SKIP_RPATH=ON \
  -DCMAKE_BUILD_TYPE=Release
make -j"$(nproc)"
```

Output:

```text
pc/build64/bin/AnimalCrossing
```

#### Optional Linux CMake flags

| Flag | Default | Description |
|------|---------|-------------|
| `-DPC_64BIT=ON` | `OFF` | Build the experimental 64-bit port. Required when using a 64-bit compiler. |
| `-DPC_PIE=ON` | `OFF` | Build the Linux executable as PIE (`-fPIE`/`-pie`). Also builds vendored SDL2 with PIC flags. Experimental. |
| `-DPC_SYSTEM_SDL2=ON` | `OFF` | Use system SDL2 / `sdl2-compat` instead of the vendored static SDL2 build. Requires system SDL2 development files such as `sdl2.pc`. |
| `-DPC_CONSOLE=ON` | `OFF` | Windows-only: keep a console window visible for debugging. |

Examples:

```bash
# 64-bit + PIE
cmake .. -DPC_64BIT=ON -DPC_PIE=ON -DCMAKE_SKIP_RPATH=ON -DCMAKE_BUILD_TYPE=Release

# 64-bit + system SDL2/sdl2-compat
cmake .. -DPC_64BIT=ON -DPC_SYSTEM_SDL2=ON -DCMAKE_SKIP_RPATH=ON -DCMAKE_BUILD_TYPE=Release

# 64-bit + PIE + system SDL2/sdl2-compat
cmake .. -DPC_64BIT=ON -DPC_PIE=ON -DPC_SYSTEM_SDL2=ON -DCMAKE_SKIP_RPATH=ON -DCMAKE_BUILD_TYPE=Release
```

On Fedora, `PC_SYSTEM_SDL2=ON` typically requires:

```bash
sudo dnf install SDL2-devel
```

or whichever package provides `sdl2.pc` for your SDL2/`sdl2-compat` setup.

#### Container build 32-bit

```bash
# Build the container (one-time, takes a few minutes)
podman build --no-cache -t acgc-build -f Containerfile .

# Extract the binary
mkdir -p pc/build32/bin
podman run --rm -v "$PWD/pc/build32":/out:Z acgc-build \
    sh -c 'cp /build/project/pc/build32/bin/AnimalCrossing /out/'

# Place your disc image
mkdir -p pc/build32/bin/rom
cp path/to/your/game.ciso pc/build32/bin/rom/
```

#### Running

Place your disc image in the matching build directory:

```bash
mkdir -p pc/build64/bin/rom
cp path/to/your/game.ciso pc/build64/bin/rom/
cd pc/build64/bin
./AnimalCrossing --verbose
```

For the 32-bit build, use `pc/build32/bin/rom/` instead.

On Linux, OpenGL is provided by the host Mesa/driver stack. Some Fedora/multilib setups have LLVM/Mesa static-initializer crashes when the Mesa GLX/EGL vendor library loads LLVM. If you are debugging video-driver selection, force desktop OpenGL/X11 with:

```bash
DISPLAY=:0 SDL_VIDEODRIVER=x11 SDL_VIDEO_GL_DRIVER=libGL.so.1 ./AnimalCrossing --verbose
```

See [distrobox-test.ini](distrobox-test.ini) for a runtime package list.

### 🪟 Windows (MSYS2)

### Build Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/flyngmt/ACGC-PC-Port.git
   cd ACGC-PC-Port
   ```

2. Build (from **MSYS2 MINGW32** shell):
   ```bash
   ./build_pc.sh
   ```

3. Place your disc image in the `rom/` folder:
   ```
   pc/build32/bin/rom/YourGame.ciso
   ```

4. Run:
   ```bash
   pc/build32/bin/AnimalCrossing.exe
   ```

## Controls

Keyboard bindings are customizable via `keybindings.ini` (next to the executable). Mouse buttons (Mouse1/Mouse2/Mouse3) can also be assigned.

### Keyboard (defaults)

| Key | Action |
|-----|--------|
| WASD | Move (left stick) |
| Arrow Keys | Camera (C-stick) |
| Space | A button |
| Left Shift | B button |
| Enter | Start |
| X | X button |
| Y | Y button |
| Q / E | L / R triggers |
| Z | Z trigger |
| I / J / K / L | D-pad (up/left/down/right) |

### Gamepad

SDL2 game controllers are supported with automatic hotplug detection. Button mapping follows the standard GameCube layout.

## Command Line Options

| Flag | Description |
|------|-------------|
| `--verbose` | Enable diagnostic logging |
| `--no-framelimit` | Disable frame limiter (unlocked FPS) |
| `--model-viewer [index]` | Launch debug model viewer (structures, NPCs, fish) |
| `--time HOUR` | Override in-game hour (0-23) |

## Settings

Graphics settings are stored in `settings.ini` and can be edited manually or through the in-game options menu:

- Resolution (up to 4K)
- Fullscreen toggle
- VSync
- MSAA (anti-aliasing)
- Texture Loading/Caching (No need to enable if you aren't using a texture pack)

## Texture Packs

Custom textures can be placed in `texture_pack/`. Dolphin-compatible format (XXHash64, DDS).

I highly recommend the following texture pack from the talented artists of Animal Crossing community.

[HD Texture Pack](https://forums.dolphin-emu.org/Thread-animal-crossing-hd-texture-pack-version-23-feb-22nd-2026)

## Save Data

Save files are stored in `save/` using the standard GCI format, compatible with Dolphin emulator saves. Place a Dolphin GCI export in the save directory to import an existing save.

## Credits

This project would not be possible without the work of the [ACreTeam](https://github.com/ACreTeam) decompilation team. Their complete C decompilation of Animal Crossing is the foundation this port is built on.

## AI Notice

AI tools such as Claude were used in this project (PC port code only).

Additional: DeepSeek v4 and GPT-5.5 were also used for AI-assisted Linux porting
and debugging.

## FAQ

See [FAQ](FAQ.md) for more info.
