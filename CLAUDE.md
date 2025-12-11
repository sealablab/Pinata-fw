# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pinata is firmware for an ARM Cortex-M4F development board (STM32F4Discovery) designed as a training target for Side-Channel Analysis (SCA) and Fault Injection (FI) attacks on cryptographic implementations. Developed by Riscure B.V.

## Build Commands

### Check Environment
```sh
./scripts/check-toolchain.sh    # Verify toolchain is installed
```

### Install Toolchain

```sh
# Ubuntu/Debian
sudo apt-get install gcc-arm-none-eabi libnewlib-arm-none-eabi cmake dfu-util

# macOS (Homebrew)
brew tap osx-cross/arm && brew install arm-gcc-bin@14

# Portable (any platform, no root)
./scripts/download-toolchain.sh
```

### Cross-compile firmware (using presets)
```sh
cmake --preset linux      # or: macos, portable, ci
cmake --build --preset linux
```

### Build specific target
```sh
cmake --build --preset linux --target classic_bin    # Classic firmware binary
cmake --build --preset linux --target hw_bin         # Hardware crypto variant
cmake --build --preset linux --target pqc_bin        # Post-quantum crypto variant
```

### Flash to device
```sh
cmake --build --preset linux --target classic_flash  # Also rebuilds if needed
```

### Available Presets
| Preset | Platform | Description |
|--------|----------|-------------|
| `linux` | Linux | System-installed toolchain |
| `macos` | macOS | Homebrew toolchain |
| `portable` | Any | `$HOME/arm-gnu-toolchain` |
| `ci` | Any | CI/CD environments |

## Testing

Tests require a physical Pinata device connected via USB serial.

### Build tests
```sh
git submodule update --init --recursive
sudo apt install libboost-dev libssl-dev libgtest-dev
cd PinataTests && cmake -S. -Bbuild && cd build && make
```

### Run tests
```sh
export SERIAL_PORT=/dev/serial/by-id/<your-device>
./PinataTests/build/PinataTests
./PinataTests/build/PinataTests --gtest_filter=test128AES*  # Run specific tests
./PinataTests/build/PinataTests --gtest_list_tests          # List all tests
```

## Architecture

### Firmware Variants
Three mutually exclusive build variants:
- **classic**: Standard software cryptographic implementations
- **hw** (`HW_CRYPTO_PRESENT`): Uses STM32F4 hardware crypto accelerator
- **pqc** (`VARIANT_PQC`): Post-Quantum Cryptography only (excludes classic ciphers)

Note: `HW_CRYPTO_PRESENT` and `VARIANT_PQC` cannot be combined.

### Key Source Files
- `src/main.c` - Command dispatcher handling all crypto operations over USB CDC
- `src/main.h` - Command byte definitions and protocol constants
- `src/io.h` - Serial I/O interface

### Cryptographic Implementations
| Directory | Algorithm |
|-----------|-----------|
| `src/swAES/` | AES-128 with countermeasures (masking, random delays, S-box shuffling) |
| `src/swAES256/` | AES-256 |
| `src/swAES_Ttables/` | T-table based AES |
| `src/swmAES/` | Masked AES |
| `src/swDES/` | DES with countermeasures |
| `src/rsa/` | RSA-1024 with CRT |
| `src/rsacrt/` | RSA-512 with SFM |
| `src/ecc/` | ECC25519 scalar multiplication |
| `src/dilithium/` | CRYSTALS-Dilithium Level 3 |
| `src/kyber512/` | CRYSTALS-Kyber512 |
| `src/sm4/` | SM4 cipher |
| `src/present/` | PRESENT lightweight cipher |
| `src/tea/` | TEA/XTEA |

### Hardware Support
| Directory | Purpose |
|-----------|---------|
| `src/cmsis/` | ARM CMSIS library |
| `src/cmsis_boot/` | STM32F4 boot/init |
| `src/cmsis_lib/` | STM32F4 peripheral libraries |
| `src/usb_lib/` | USB OTG/CDC |
| `src/ssd1306/` | OLED display driver |

## Communication Protocol

- **Interface**: USB CDC virtual COM port
- **Settings**: 115200 baud, 8N1, no flow control
- **Commands**: Single-byte command codes defined in `src/main.h` (e.g., `CMD_SWAES128_ENC = 0xAE`)
- **Trigger pin**: PC2 GPIO for side-channel analysis timing

## Hardware Target

- **Board**: STM32F4Discovery
- **Processor**: ARM Cortex-M4F
- **Flash**: 1 MB (0x08000000)
- **RAM**: 192 KB
- **Linker script**: `arm-gcc-link.ld`

## Build Configuration Notes

- Build optimization: MinSizeRel (size-optimized for firmware constraints)
- Random signing for Dilithium: Enable with `-DRANDOM_SIGNING=ON`
- Third-party licenses auto-generated in `ThirdPartyLicenses.txt`

### Toolchain Configuration

The toolchain auto-detects common paths. Override with environment variables:

| Variable | Description |
|----------|-------------|
| `ARM_TOOLCHAIN_DIR` | Root of extracted toolchain (e.g., `$HOME/arm-gnu-toolchain`) |
| `ARM_PREFIX` | Full prefix path (e.g., `/usr/bin/arm-none-eabi-`) |

Or pass directly to CMake: `-DPREFIX=/path/to/arm-none-eabi-`

### Helper Scripts

| Script | Purpose |
|--------|---------|
| `scripts/check-toolchain.sh` | Validate build environment |
| `scripts/download-toolchain.sh` | Download ARM toolchain (no root required) |
