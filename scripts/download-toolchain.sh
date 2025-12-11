#!/bin/bash
# download-toolchain.sh - Download ARM GNU Toolchain (portable, no root required)
#
# Downloads the official ARM GNU Toolchain from developer.arm.com
# Extracts to $HOME/arm-gnu-toolchain by default

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Toolchain version and URLs
TOOLCHAIN_VERSION="14.2.rel1"
TOOLCHAIN_BASE="arm-gnu-toolchain-${TOOLCHAIN_VERSION}"

# Detect platform
case "$(uname -s)" in
    Linux)
        case "$(uname -m)" in
            x86_64)
                TOOLCHAIN_ARCHIVE="${TOOLCHAIN_BASE}-x86_64-arm-none-eabi.tar.xz"
                ;;
            aarch64)
                TOOLCHAIN_ARCHIVE="${TOOLCHAIN_BASE}-aarch64-arm-none-eabi.tar.xz"
                ;;
            *)
                echo -e "${RED}Unsupported Linux architecture: $(uname -m)${NC}"
                exit 1
                ;;
        esac
        ;;
    Darwin)
        case "$(uname -m)" in
            x86_64)
                TOOLCHAIN_ARCHIVE="${TOOLCHAIN_BASE}-darwin-x86_64-arm-none-eabi.tar.xz"
                ;;
            arm64)
                TOOLCHAIN_ARCHIVE="${TOOLCHAIN_BASE}-darwin-arm64-arm-none-eabi.tar.xz"
                ;;
            *)
                echo -e "${RED}Unsupported macOS architecture: $(uname -m)${NC}"
                exit 1
                ;;
        esac
        ;;
    *)
        echo -e "${RED}Unsupported operating system: $(uname -s)${NC}"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://developer.arm.com/-/media/Files/downloads/gnu/${TOOLCHAIN_VERSION}/binrel/${TOOLCHAIN_ARCHIVE}"

# Installation directory
INSTALL_DIR="${ARM_TOOLCHAIN_DIR:-$HOME/arm-gnu-toolchain}"

echo "=== ARM GNU Toolchain Installer ==="
echo ""
echo "Version:     ${TOOLCHAIN_VERSION}"
echo "Archive:     ${TOOLCHAIN_ARCHIVE}"
echo "Install to:  ${INSTALL_DIR}"
echo ""

# Check if already installed
if [ -x "${INSTALL_DIR}/bin/arm-none-eabi-gcc" ]; then
    INSTALLED_VERSION=$("${INSTALL_DIR}/bin/arm-none-eabi-gcc" --version | head -1)
    echo -e "${YELLOW}Toolchain already installed:${NC}"
    echo "  $INSTALLED_VERSION"
    echo ""
    read -p "Reinstall? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing installation."
        exit 0
    fi
    rm -rf "${INSTALL_DIR}"
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Downloading toolchain..."
echo "URL: ${DOWNLOAD_URL}"
echo ""

# Download with progress
if command -v curl &>/dev/null; then
    curl -L --progress-bar -o "${TEMP_DIR}/${TOOLCHAIN_ARCHIVE}" "${DOWNLOAD_URL}"
elif command -v wget &>/dev/null; then
    wget --show-progress -O "${TEMP_DIR}/${TOOLCHAIN_ARCHIVE}" "${DOWNLOAD_URL}"
else
    echo -e "${RED}Error: curl or wget required for download${NC}"
    exit 1
fi

echo ""
echo "Extracting..."

# Create install directory
mkdir -p "${INSTALL_DIR}"

# Extract (strip the top-level directory)
tar -xf "${TEMP_DIR}/${TOOLCHAIN_ARCHIVE}" -C "${INSTALL_DIR}" --strip-components=1

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "Toolchain installed to: ${INSTALL_DIR}"
echo ""
echo "Add to your environment:"
echo ""
echo "  export ARM_PREFIX=\"${INSTALL_DIR}/bin/arm-none-eabi-\""
echo ""
echo "Or for CMake presets, set ARM_TOOLCHAIN_DIR:"
echo ""
echo "  export ARM_TOOLCHAIN_DIR=\"${INSTALL_DIR}\""
echo ""
echo "Verify installation:"
echo ""
echo "  ${INSTALL_DIR}/bin/arm-none-eabi-gcc --version"
echo ""

# Verify
if [ -x "${INSTALL_DIR}/bin/arm-none-eabi-gcc" ]; then
    echo "Installed version:"
    "${INSTALL_DIR}/bin/arm-none-eabi-gcc" --version | head -1
    exit 0
else
    echo -e "${RED}Installation verification failed${NC}"
    exit 1
fi
