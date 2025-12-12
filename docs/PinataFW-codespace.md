---
created: 2025-12-11
modified: 2025-12-11 16:56:56
accessed: 2025-12-11 17:14:54
---
# Building Pinata in GitHub Codespaces

GitHub Codespaces provides a complete cloud development environment with the ARM toolchain pre-installed. No local setup required.

## What is a Codespace?

A Codespace is a cloud-hosted development environment that runs VS Code in your browser. It uses the `.devcontainer` configuration in this repo to automatically set up:

- ARM cross-compiler (`gcc-arm-none-eabi`)
- CMake and build tools
- VS Code extensions for C/C++ and embedded development
- Debugging tools (OpenOCD, GDB)

## Quick Start (2 minutes)

### 1. Create a Codespace

**Option A: From the repository**
1. Go to [github.com/sealablab/Pinata-fw](https://github.com/sealablab/Pinata-fw)
2. Click the green **Code** button
3. Select the **Codespaces** tab
4. Click **Create codespace on main**

**Option B: From a template (if repo is a template)**
1. Click **Use this template** → **Open in a codespace**

The Codespace takes ~2-3 minutes to build on first launch.

### 2. Build the Firmware

When the Codespace opens, the project is already configured. Open a terminal (`Ctrl+`` ` or View → Terminal) and run:

```sh
cmake --build build
```

That's it! Binaries are in `build/src/`:
- `classic.elf` - Standard crypto implementations
- `hw.elf` - Hardware crypto accelerator
- `pqc.elf` - Post-quantum crypto (Dilithium, Kyber)

### 3. Build a Specific Variant

```sh
cmake --build build --target classic_bin   # Creates flashable .bin
cmake --build build --target pqc_bin
cmake --build build --target hw_bin
```

## Using VS Code in the Codespace

The Codespace comes with CMake Tools extension pre-configured:

1. **Build**: Press `F7` or click **Build** in the status bar
2. **Select target**: `Ctrl+Shift+P` → "CMake: Set Build Target"
3. **Clean rebuild**: `Ctrl+Shift+P` → "CMake: Clean Rebuild"

## Forking and Customizing

1. Fork this repository (or use as template)
2. Create a Codespace from your fork
3. Make changes and commit directly from VS Code
4. Push to your fork

## Limitations

- **No USB access**: Codespaces can't flash physical hardware directly
- **Download binaries**: Use `gh` CLI or commit to download `.bin` files:
  ```sh
  # Download to your local machine
  gh codespace cp remote:build/src/classic.bin .
  ```

## Troubleshooting

**Codespace won't start**
- Check [GitHub Status](https://githubstatus.com) for outages
- Try a different region: Codespace settings → change location

**Build fails with toolchain error**
- The devcontainer should have the toolchain. Try rebuilding:
  ```sh
  rm -rf build && cmake -DCMAKE_TOOLCHAIN_FILE=gcc-arm-none-eabi.toolchain.cmake -S. -Bbuild
  ```

**Out of disk space**
- Codespaces have limited storage. Clean build artifacts:
  ```sh
  cmake --build build --target clean
  ```

## Cost

- GitHub Free: 120 core-hours/month of Codespaces
- Sufficient for occasional firmware development
- Stop Codespaces when not in use to conserve hours

# See Also
- [CMakePresets](CMAKEPresets.md)
- [arm-none-eabi-gcc](arm-none-eabi-gcc.md)
- [GitHub Codespaces documentation](https://docs.github.com/en/codespaces)

