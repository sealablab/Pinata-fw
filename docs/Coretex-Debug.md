---
created: 2025-12-11
modified: 2025-12-11 19:41:16
accessed: 2025-12-11 19:42:14
---
# Cortex-Debug

[Cortex-Debug](https://marketplace.visualstudio.com/items?itemName=marus25.cortex-debug) is a VS Code extension that provides debugging support for ARM Cortex-M microcontrollers. It's the bridge between VS Code's debug UI and the low-level debug tools (GDB, OpenOCD) that talk to the hardware.

## What It Does

```
┌─────────────────────────────────────────────────────────────┐
│  VS Code                                                    │
│  ┌─────────────────┐                                        │
│  │ Debug UI        │  breakpoints, stepping, variables      │
│  │ (F5, F10, F11)  │                                        │
│  └────────┬────────┘                                        │
│           │                                                 │
│  ┌────────▼────────┐                                        │
│  │ Cortex-Debug    │  translates UI actions to GDB commands │
│  │ Extension       │  parses ELF files, SVD registers       │
│  └────────┬────────┘                                        │
└───────────┼─────────────────────────────────────────────────┘
            │
   ┌────────▼────────┐
   │ GDB             │  gdb-multiarch / arm-none-eabi-gdb
   │ (debugger)      │  executes debug commands
   └────────┬────────┘
            │ GDB Remote Protocol (port 3333)
   ┌────────▼────────┐
   │ OpenOCD         │  on-chip debugger server
   │ (debug server)  │  translates to SWD/JTAG
   └────────┬────────┘
            │ SWD or JTAG
   ┌────────▼────────┐
   │ ST-Link/Tigard  │  USB debug probe
   │ (hardware)      │
   └────────┬────────┘
            │
   ┌────────▼────────┐
   │ STM32F4         │  target microcontroller
   │ Discovery       │
   └─────────────────┘
```

## Dev Container Integration

The `.devcontainer/Dockerfile` installs all the debug tooling:

```dockerfile
# Debugging tools
gdb-multiarch \
openocd \
```

And creates a symlink so Cortex-Debug can find GDB:

```dockerfile
RUN ln -sf /usr/bin/gdb-multiarch /usr/bin/arm-none-eabi-gdb
```

The `.devcontainer/devcontainer.json` configures VS Code to:

1. **Install the extension automatically**:
   ```json
   "extensions": [
       "marus25.cortex-debug"
   ]
   ```

2. **Configure paths** so Cortex-Debug finds the tools:
   ```json
   "settings": {
       "cortex-debug.armToolchainPath": "/usr/bin",
       "cortex-debug.openocdPath": "/usr/bin/openocd",
       "cortex-debug.gdbPath": "/usr/bin/gdb-multiarch"
   }
   ```

3. **Enable USB passthrough** for hardware access:
   ```json
   "runArgs": ["--privileged"],
   "mounts": ["source=/dev,target=/dev,type=bind"]
   ```

## Launch Configuration

The `.vscode/launch.json` defines debug sessions. Example:

```json
{
    "name": "Debug Classic (OpenOCD)",
    "type": "cortex-debug",
    "request": "launch",
    "servertype": "openocd",
    "executable": "${workspaceFolder}/build/src/classic.elf",
    "device": "STM32F407VG",
    "configFiles": [
        "interface/stlink.cfg",
        "target/stm32f4x.cfg"
    ],
    "runToEntryPoint": "main"
}
```

| Field | Purpose |
|-------|---------|
| `type` | Must be `cortex-debug` |
| `servertype` | Debug server: `openocd`, `jlink`, `stutil`, etc. |
| `executable` | ELF file with debug symbols |
| `device` | MCU name (for register definitions) |
| `configFiles` | OpenOCD config for interface + target |
| `runToEntryPoint` | Function to break at on start |

## Key Features

### Peripheral Register View

With an SVD file, you can view/modify hardware registers:

```json
"svdFile": "${workspaceFolder}/.vscode/STM32F407.svd"
```

Then in the Debug sidebar, expand "Cortex Peripherals" to see GPIO, USART, timers, etc.

### Memory Viewer

Command Palette → "Cortex-Debug: View Memory" → enter address like `0x20000000`

### Live Watch

Add expressions to Watch panel: `*((uint32_t*)0x40020014)` to read `GPIOA->ODR`

### Disassembly

Right-click in editor during debug → "Open Disassembly View"

## Supported Debug Probes

| Probe | `servertype` | Config Files |
|-------|-------------|--------------|
| ST-Link (onboard) | `openocd` | `interface/stlink.cfg` |
| Tigard (SWD) | `openocd` | `openocd/tigard-swd.cfg` |
| Tigard (JTAG) | `openocd` | `openocd/tigard-jtag.cfg` |
| J-Link | `jlink` | (auto-detected) |
| Black Magic Probe | `bmp` | (serial port) |

## Troubleshooting

**"Unable to start GDB server"**
- OpenOCD can't connect to probe. Check USB connection and `lsusb` output.

**"No register file available"**
- Add `svdFile` to launch.json or download [STM32F407.svd](https://github.com/posborne/cmsis-svd/blob/master/data/STMicro/STM32F407.svd)

**Variables show `<optimized out>`**
- Code is compiled with optimization. Set breakpoint on function entry, or rebuild with `-O0`.

**"Error: target not halted"**
- Target is running. Use pause button or add `"runToEntryPoint": "main"` to halt on start.

## Why Docker + Debugging is Tricky

Debugging embedded hardware from a container requires USB passthrough:

1. **Privileged mode**: Container needs access to USB devices
2. **Device mount**: `/dev` must be accessible for ST-Link/Tigard
3. **Host location**: USB device must be physically connected to the Docker host

If you're connecting to REBox remotely from a Mac, the STM32F4Discovery must be plugged into REBox (not the Mac) for debugging to work.

# See also
- [vscode-debugging](vscode-debugging.md) - Step-by-step debugging guide
- [vscode-tasks](vscode-tasks.md) - Build tasks
- [README](README.md) - Tigard wiring and hardware setup
