---
created: 2025-12-11
modified: 2025-12-11 16:33:31
accessed: 2025-12-11 16:32:56
type: N
---

# [CMakePresets.json](https://code.visualstudio.com/docs/cpp/cmake-quickstart#_create-a-cmakepresetsjson-file)

CMakePresets.json provides a standardized way to configure CMake builds across different platforms and IDEs.

## Quick Start

```sh
# List available presets
cmake --list-presets

# Configure (pick one)
cmake --preset macos
cmake --preset linux

# Build
cmake --build --preset macos
cmake --build --preset linux

# Verbose build output
cmake --build --preset macos-verbose
```

## VS Code Integration

1. Install the **CMake Tools** extension
2. Open the project folder
3. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
4. Type "CMake: Select Configure Preset" and select your platform
5. Click the Build button in the status bar (or press `F7`)

## Available Presets

| Preset | Platform | Description |
|--------|----------|-------------|
| `macos` | macOS | Auto-detects Homebrew toolchain |
| `linux` | Linux | Auto-detects system toolchain |
| `portable` | Any | Uses `$HOME/arm-gnu-toolchain` (download with `scripts/download-toolchain.sh`) |
| `ci` | Any | For CI/CD - inherits from portable |

## Cloud/CI Environments

For environments without package manager access:

```sh
# Download toolchain (requires network)
./scripts/download-toolchain.sh

# Build
cmake --preset ci
cmake --build --preset ci
```

## Toolchain Auto-Detection

The toolchain file searches these locations in order:

1. `ARM_TOOLCHAIN_DIR` environment variable
2. `ARM_PREFIX` environment variable
3. Platform defaults:
   - macOS: `/opt/homebrew/opt/arm-gcc-bin@14/bin/arm-none-eabi-`
   - Linux: `$HOME/arm-gnu-toolchain/bin/arm-none-eabi-` or `/usr/bin/arm-none-eabi-`

## Preset Structure

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "portable",
      "displayName": "Portable Toolchain",
      "binaryDir": "${sourceDir}/build",
      "toolchainFile": "${sourceDir}/gcc-arm-none-eabi.toolchain.cmake",
      "environment": {
        "ARM_TOOLCHAIN_DIR": "$penv{HOME}/arm-gnu-toolchain"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "portable",
      "configurePreset": "portable"
    }
  ]
}
```

## User Overrides (CMakeUserPresets.json)

Create `CMakeUserPresets.json` (gitignored) for personal settings:

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "my-macos",
      "inherits": "macos",
      "cacheVariables": {
        "PREFIX": "/custom/path/to/arm-none-eabi-"
      }
    }
  ]
}
```

# See also
- [cmake-quickstart](cmake-quickstart.md)
- [arm-none-eabi-gcc](arm-none-eabi-gcc.md)
