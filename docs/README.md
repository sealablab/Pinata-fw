---
created: 2025-12-11
modified: 2025-12-11 16:10:04
accessed: 2025-12-11 16:00:05
---
# [README](Pinata-fw/docs/README.md)
This [repo](https://github.com/sealablab/Pinata-fw) exists to be an AI/LLM/Container friendly fork of the [upstream Pinata firmware](https://github.com/Keysight/Pinata)

## Container-First Development

This repository includes a devcontainer configuration that provides a complete development environment with:

- **ARM Cross-Compiler**: `gcc-arm-none-eabi` toolchain for Cortex-M4
- **Build Tools**: CMake, Ninja
- **Debugging**: GDB (multiarch), OpenOCD
- **Flashing**: dfu-util for programming the STM32F4
- **Test Dependencies**: Boost, OpenSSL, GTest

### Using with Claude Code Web / GitHub Codespaces

1. Open this repository in Claude Code Web or GitHub Codespaces
2. The devcontainer will automatically build and configure the environment
3. The build system is pre-configured on container creation

### Using with VS Code + Docker

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open the repository in VS Code
3. Click "Reopen in Container" when prompted (or use Command Palette: "Dev Containers: Reopen in Container")

### Manual Docker Build

```sh
# Build the container
docker build -t pinata-dev -f .devcontainer/Dockerfile .

# Run interactively
docker run -it --rm -v $(pwd):/workspaces/Pinata-fw -w /workspaces/Pinata-fw pinata-dev

# Inside container: configure and build
cmake -DCMAKE_TOOLCHAIN_FILE=gcc-arm-none-eabi.toolchain.cmake -S. -Bbuild
cmake --build build
```

### What's Included

| Tool | Purpose |
|------|---------|
| `gcc-arm-none-eabi` | ARM Cortex-M cross-compiler |
| `cmake` | Build system generator |
| `ninja-build` | Fast build tool |
| `gdb-multiarch` | Debugger for ARM targets |
| `openocd` | On-chip debugger interface |
| `dfu-util` | USB DFU flashing utility |
| `picocom` | Serial terminal for device communication |

## Debugging with Tigard

The repository includes OpenOCD configurations for using a [Tigard](https://github.com/tigard-tools/tigard) (FTDI FT2232H-based) debug probe with the STM32F4 Discovery board.

### Hardware Setup

1. **Remove CN3 jumpers** from the STM32F4Discovery board (disconnects onboard ST-LINK)
2. Set Tigard **mode switch** to `SWD/I2C` (for SWD) or `JTAG` (for JTAG)
3. Set Tigard **power switch** to `3V3` or use target's own power
4. Connect Tigard to SWD port:

| Tigard CORTEX | STM32F4 SWD |
|---------------|-------------|
| VTGT          | Pin 1 (VDD) |
| SWCLK         | Pin 2       |
| GND           | Pin 3       |
| SWDIO         | Pin 4       |

### Start OpenOCD

```sh
# SWD mode (recommended)
openocd -f openocd/tigard-swd.cfg

# JTAG mode
openocd -f openocd/tigard-jtag.cfg
```

### Connect GDB

```sh
# In another terminal
arm-none-eabi-gdb build/classic.elf -ex "target extended-remote :3333"

# Useful GDB commands
(gdb) monitor reset halt    # Reset and halt target
(gdb) load                  # Flash the firmware
(gdb) continue              # Run
```

### Flash via OpenOCD (without GDB)

```sh
openocd -f openocd/tigard-swd.cfg \
    -c "program build/classic.bin 0x08000000 verify reset exit"
```

### Troubleshooting Tigard

- **"Error connecting DP: cannot read IDR"**: Ensure CN3 jumpers are removed and USB is disconnected from onboard ST-LINK
- **Permission denied**: Run `sudo usermod -aG plugdev $USER` and re-login
- **Device not found**: Check `lsusb` for `0403:6010` (FTDI FT2232H)

# See also
