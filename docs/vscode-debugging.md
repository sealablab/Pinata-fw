---
created: 2025-12-11
modified: 2025-12-11
---
# VS Code Debugging

Debug Pinata firmware directly from VS Code using Cortex-Debug and OpenOCD.

## Prerequisites

- STM32F4Discovery board connected via ST-Link or Tigard
- Dev Container running (provides OpenOCD, GDB, Cortex-Debug)

## Quick Start

1. **Build**: Press `Ctrl+Shift+B` → select "Build: Classic Firmware"
2. **Set breakpoint**: Click in the gutter (left of line numbers) in any `.c` file
3. **Debug**: Press `F5` → select "Debug Classic (OpenOCD)"
4. The debugger halts at `main()` by default

## Debug Configurations

| Configuration | Firmware | Use Case |
|---------------|----------|----------|
| Debug Classic (OpenOCD) | `classic.elf` | Standard crypto implementations |
| Debug HW Crypto (OpenOCD) | `hw.elf` | Hardware crypto accelerator |
| Debug PQC (OpenOCD) | `pqc.elf` | Post-quantum (Dilithium, Kyber) |
| Attach Classic (OpenOCD) | `classic.elf` | Attach to running firmware |

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `F5` | Start debugging / Continue |
| `F9` | Toggle breakpoint |
| `F10` | Step Over |
| `F11` | Step Into |
| `Shift+F11` | Step Out |
| `Shift+F5` | Stop debugging |
| `Ctrl+Shift+F5` | Restart debugging |

## Debug Features

### Breakpoints

- **Line breakpoints**: Click gutter or press `F9`
- **Conditional**: Right-click breakpoint → "Edit Breakpoint" → add condition
- **Function breakpoints**: Run/Debug sidebar → Breakpoints → "+" → enter function name

### Watch Expressions

1. Open Run/Debug sidebar (`Ctrl+Shift+D`)
2. In "Watch" section, click "+"
3. Enter variable or expression (e.g., `plaintext[0]`, `*key`)

### Peripheral Registers

With an SVD file installed (`.vscode/STM32F407.svd`):

1. During debug, expand "Cortex Peripherals" in sidebar
2. View/modify GPIO, USART, timers, etc.

To install SVD file:
```sh
curl -L -o .vscode/STM32F407.svd \
  https://raw.githubusercontent.com/posborne/cmsis-svd/master/data/STMicro/STM32F407.svd
```

### Memory View

1. During debug, open Command Palette (`Ctrl+Shift+P`)
2. Type "Cortex-Debug: View Memory"
3. Enter address (e.g., `0x20000000` for RAM start)

## Hardware Setup

### Using ST-Link (Onboard)

The STM32F4Discovery has an onboard ST-Link. Just connect USB to the `CN1` mini-USB port.

### Using Tigard (External)

See [README - Debugging with Tigard](README.md#debugging-with-tigard) for wiring.

Change `.vscode/launch.json` config files:
```json
"configFiles": [
    "openocd/tigard-swd.cfg"
]
```

## Dev Container USB Access

For debugging from within a Dev Container, USB passthrough is required. The devcontainer.json includes:

```json
"runArgs": ["--privileged"],
"mounts": ["source=/dev,target=/dev,type=bind"]
```

Verify device access inside container:
```sh
lsusb | grep -i stm    # Should show ST-Link
ls /dev/ttyACM*        # Serial port for CDC
```

## Troubleshooting

**"Error: libusb_open() failed"**
- Ensure ST-Link USB is connected to the host running Docker (not a remote machine)
- Check udev rules: `ls -la /dev/bus/usb/*/*`

**"Error connecting DP"**
- Board not powered or USB not connected
- If using Tigard, ensure CN3 jumpers are removed

**"No executable specified"**
- Run a build first (`Ctrl+Shift+B`)
- Check that `build/src/classic.elf` exists

**Breakpoints not hitting**
- Ensure build is `Debug` or `RelWithDebInfo`, not `MinSizeRel`
- For optimized builds, set breakpoints on function entry

**GDB timeout**
- Increase timeout in launch.json: `"timeout": 10000`

# See also
- [vscode-tasks](vscode-tasks.md)
- [cmake-quickstart](cmake-quickstart.md)
- [README - Debugging with Tigard](README.md)
