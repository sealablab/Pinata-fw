---
created: 2025-12-11
modified: 2025-12-11
---
# VS Code Tasks

Pre-configured build and flash tasks for the Pinata firmware.

## Quick Start

Press `Ctrl+Shift+B` to open the build task menu, then select a task.

## Available Tasks

### Build Tasks

| Task | Description | Shortcut |
|------|-------------|----------|
| Build: Classic Firmware | Standard crypto (default) | `Ctrl+Shift+B` → Enter |
| Build: Hardware Crypto Firmware | STM32 HW accelerator | `Ctrl+Shift+B` → select |
| Build: PQC Firmware | Dilithium + Kyber | `Ctrl+Shift+B` → select |
| Build: All Variants | All three binaries | `Ctrl+Shift+B` → select |
| Clean Build | Remove `build/` directory | `Ctrl+Shift+B` → select |

### Flash Tasks

| Task | Description |
|------|-------------|
| Flash: Classic Firmware | Build and flash via DFU |
| Flash: Hardware Crypto Firmware | Build and flash via DFU |
| Flash: PQC Firmware | Build and flash via DFU |

## Running Tasks

### From Menu

1. Press `Ctrl+Shift+B` (build tasks) or `Ctrl+Shift+P` → "Tasks: Run Task"
2. Select the task from the list
3. View output in the Terminal panel

### Default Build Task

"Build: Classic Firmware" is set as default. Press `Ctrl+Shift+B` then Enter.

### From Terminal

```sh
# Equivalent to "Build: Classic Firmware" task
cmake --build --preset linux --target classic
```

## Task Dependencies

Build tasks automatically run "CMake: Configure (Linux)" first if needed. You don't need to manually configure.

## Output Location

After building:

```
build/src/
├── classic.elf    # ELF with debug symbols
├── classic.dfu    # Flashable DFU image
├── classic.map    # Linker map file
├── hw.elf
├── hw.dfu
├── pqc.elf
└── pqc.dfu
```

## Customizing Tasks

Edit `.vscode/tasks.json` to modify or add tasks. Example custom task:

```json
{
    "label": "Build: Classic (Verbose)",
    "type": "shell",
    "command": "cmake",
    "args": ["--build", "--preset", "linux-verbose", "--target", "classic"],
    "group": "build",
    "problemMatcher": "$gcc"
}
```

## Problem Matcher

Tasks use the `$gcc` problem matcher, which:
- Parses compiler errors and warnings
- Shows them in the Problems panel (`Ctrl+Shift+M`)
- Enables click-to-navigate to error location

## Flashing Requirements

Flash tasks require:
1. Board in DFU mode (hold BOOT0, press RESET, release BOOT0)
2. `dfu-util` installed (included in Dev Container)
3. USB access to the STM32 DFU device

Verify DFU mode:
```sh
dfu-util -l    # Should show STM32 DFU device
```

# See also
- [vscode-debugging](vscode-debugging.md)
- [cmake-quickstart](cmake-quickstart.md)
- [CMakePresets](CMAKEPresets.md)
