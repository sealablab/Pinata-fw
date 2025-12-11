---
created: 2025-12-11
modified: 2025-12-11 16:29:40
accessed: 2025-12-11 16:22:15
type: N
---
# arm-none-eabi-gcc

Platform-specific guidance for installing the ARM embedded toolchain.

## Quick Check

Verify your toolchain setup:

```sh
./scripts/check-toolchain.sh
```

## Portable Install (Any Platform)

No root access required. Works in CI/cloud environments:

```sh
./scripts/download-toolchain.sh
cmake --preset portable
cmake --build --preset portable
```

This downloads the official ARM GNU Toolchain to `$HOME/arm-gnu-toolchain`.

## macOS (Homebrew)

```sh
brew tap osx-cross/arm
brew install arm-gcc-bin@14
```

Build:

```sh
cmake --preset macos
cmake --build --preset macos
```

## Ubuntu/Debian

```sh
sudo apt-get update
sudo apt-get install gcc-arm-none-eabi libnewlib-arm-none-eabi cmake
```

Build:

```sh
cmake --preset linux
cmake --build --preset linux
```

## RHEL/Fedora/CentOS

Fedora / RHEL 8+:

```sh
sudo dnf install arm-none-eabi-gcc-cs arm-none-eabi-newlib cmake
```

RHEL 7 / CentOS 7:

```sh
sudo yum install arm-none-eabi-gcc-cs arm-none-eabi-newlib cmake
```

Build:

```sh
cmake --preset linux
cmake --build --preset linux
```

## Environment Variables

The toolchain file auto-detects common installation paths. Override with:

| Variable | Description |
|----------|-------------|
| `ARM_TOOLCHAIN_DIR` | Root directory of extracted toolchain |
| `ARM_PREFIX` | Full path prefix (e.g., `/usr/bin/arm-none-eabi-`) |

Example:

```sh
export ARM_TOOLCHAIN_DIR=$HOME/arm-gnu-toolchain
cmake --preset portable
```

## Verbose Output

```sh
cmake --build --preset macos-verbose
cmake --build --preset linux-verbose
```

# See Also
- [CMakePresets](CMAKEPresets.md)
- [cmake-quickstart](cmake-quickstart.md)
