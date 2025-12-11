---
created: 2025-12-11
modified: 2025-12-11 16:34:26
accessed: 2025-12-11 16:34:04
---
# [cmake-quickstart](https://code.visualstudio.com/docs/cpp/cmake-quickstart)

A beginner's guide to building this project with CMake.

## What is CMake?

CMake is a build system generator. It reads `CMakeLists.txt` files and generates platform-specific build files (Makefiles on Linux/macOS, Visual Studio projects on Windows).

## Two-Step Build Process

CMake separates **configuration** from **building**:

```sh
# Step 1: Configure (generates build files)
cmake --preset macos

# Step 2: Build (compiles the code)
cmake --build --preset macos
```

## Common Commands

| Command | Description |
|---------|-------------|
| `cmake --list-presets` | Show available configuration presets |
| `cmake --preset <name>` | Configure using a preset |
| `cmake --build --preset <name>` | Build using a preset |
| `cmake --build --preset <name> --clean-first` | Clean and rebuild |
| `cmake --build --preset <name> --target <t>` | Build specific target |

## Build Targets

This project produces three firmware variants:

```sh
# Build all variants
cmake --build --preset macos

# Build specific variant
cmake --build --preset macos --target classic
cmake --build --preset macos --target hw
cmake --build --preset macos --target pqc

# Generate .bin files for flashing
cmake --build --preset macos --target classic_bin
```

## Out-of-Source Builds

CMake uses "out-of-source" builds, keeping generated files separate from source:

```
Pinata-fw/
├── src/              # Source code (tracked in git)
├── CMakeLists.txt    # Build configuration
└── build/            # Generated files (not tracked)
    ├── Makefile
    ├── src/
    │   ├── classic.elf
    │   ├── hw.elf
    │   └── pqc.elf
    └── ...
```

To start fresh: `rm -rf build && cmake --preset macos`

## VS Code Workflow

1. Install extensions: **C/C++** and **CMake Tools**
2. Open the `Pinata-fw` folder
3. When prompted, select a configure preset
4. Use the status bar buttons or:
   - `F7` - Build
   - `Ctrl+Shift+B` - Build task
   - `Ctrl+Shift+P` → "CMake: Build Target" - Build specific target

## Troubleshooting

**"CMake Error: could not find compiler"**
- Install the ARM toolchain (see [arm-none-eabi-gcc](arm-none-eabi-gcc.md))

**"Preset not found"**
- Run from the project root directory
- Check `cmake --list-presets` for available options

**Stale build files**
- Delete the `build/` directory and reconfigure

# See also
- [CMakePresets](CMAKEPresets.md)
- [arm-none-eabi-gcc](arm-none-eabi-gcc.md)
