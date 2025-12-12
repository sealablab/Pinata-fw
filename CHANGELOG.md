# Changelog

All notable changes to the Pinata firmware project.

## [3.2.1] - 2025-12-11

### Added
- **CMake Presets**: Cross-platform build configuration (`linux`, `macos`, `portable`, `ci`)
- **Portable toolchain support**: `scripts/download-toolchain.sh` for environments without package managers
- **Toolchain validation**: `scripts/check-toolchain.sh` to verify build environment
- **GitHub Codespaces**: Full devcontainer support for cloud development
- **Documentation**:
  - `docs/cmake-quickstart.md` - CMake beginner guide
  - `docs/CMAKEPresets.md` - Preset configuration reference
  - `docs/arm-none-eabi-gcc.md` - Toolchain installation guide
  - `docs/PinataFW-codespace.md` - Codespaces quick start

### Changed
- Toolchain file auto-detects compiler paths on macOS and Linux
- Clearer error messages when ARM toolchain is missing
- Updated README with modern build workflow
- Devcontainer uses CMake presets instead of manual configuration

### Fixed
- Build failures in network-isolated CI/cloud environments

## [3.2.0] - Previous

- Initial fork from [Keysight/Pinata](https://github.com/Keysight/Pinata)
- Added container-first development environment
- Added Tigard debug probe support
