#!/bin/bash
# check-toolchain.sh - Validate ARM cross-compilation toolchain
# Returns 0 if toolchain is available, 1 otherwise

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Default prefix locations by platform
case "$(uname -s)" in
    Darwin)
        DEFAULT_PREFIXES=(
            "/opt/homebrew/opt/arm-gcc-bin@14/bin/arm-none-eabi-"
            "/opt/homebrew/bin/arm-none-eabi-"
            "/usr/local/bin/arm-none-eabi-"
        )
        ;;
    Linux)
        DEFAULT_PREFIXES=(
            "/usr/bin/arm-none-eabi-"
            "/opt/arm-gnu-toolchain/bin/arm-none-eabi-"
            "${HOME}/arm-gnu-toolchain/bin/arm-none-eabi-"
        )
        ;;
    *)
        DEFAULT_PREFIXES=("/usr/bin/arm-none-eabi-")
        ;;
esac

# Check if ARM_PREFIX is set, otherwise search defaults
find_toolchain() {
    if [ -n "$ARM_PREFIX" ]; then
        if [ -x "${ARM_PREFIX}gcc" ]; then
            echo "$ARM_PREFIX"
            return 0
        fi
    fi

    for prefix in "${DEFAULT_PREFIXES[@]}"; do
        if [ -x "${prefix}gcc" ]; then
            echo "$prefix"
            return 0
        fi
    done

    # Check PATH
    if command -v arm-none-eabi-gcc &>/dev/null; then
        echo "$(dirname "$(command -v arm-none-eabi-gcc)")/arm-none-eabi-"
        return 0
    fi

    return 1
}

print_status() {
    local name="$1"
    local status="$2"
    local detail="$3"

    if [ "$status" = "ok" ]; then
        printf "  %-20s ${GREEN}[OK]${NC} %s\n" "$name" "$detail"
    elif [ "$status" = "warn" ]; then
        printf "  %-20s ${YELLOW}[WARN]${NC} %s\n" "$name" "$detail"
    else
        printf "  %-20s ${RED}[MISSING]${NC} %s\n" "$name" "$detail"
    fi
}

check_tool() {
    local name="$1"
    local cmd="$2"

    if command -v "$cmd" &>/dev/null; then
        local version=$("$cmd" --version 2>/dev/null | head -1)
        print_status "$name" "ok" "$version"
        return 0
    else
        print_status "$name" "missing" ""
        return 1
    fi
}

echo "=== ARM Toolchain Check ==="
echo ""

ERRORS=0

# Check for ARM toolchain
echo "ARM Cross-Compiler:"
if TOOLCHAIN_PREFIX=$(find_toolchain); then
    GCC_PATH="${TOOLCHAIN_PREFIX}gcc"
    VERSION=$("$GCC_PATH" --version 2>/dev/null | head -1)
    print_status "arm-none-eabi-gcc" "ok" "$VERSION"
    echo ""
    echo "  Toolchain prefix: $TOOLCHAIN_PREFIX"

    # Export for use by caller
    export ARM_PREFIX="$TOOLCHAIN_PREFIX"
else
    print_status "arm-none-eabi-gcc" "missing" ""
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "Build Tools:"
check_tool "cmake" "cmake" || ERRORS=$((ERRORS + 1))
check_tool "make" "make" || true  # make is optional with ninja

echo ""
echo "Optional Tools:"
check_tool "dfu-util" "dfu-util" || true
check_tool "openocd" "openocd" || true

echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}=== TOOLCHAIN NOT FOUND ===${NC}"
    echo ""
    echo "The ARM cross-compiler (arm-none-eabi-gcc) is required but not installed."
    echo ""
    echo "Installation options:"
    echo ""

    case "$(uname -s)" in
        Darwin)
            echo "  macOS (Homebrew):"
            echo "    brew tap osx-cross/arm"
            echo "    brew install arm-gcc-bin@14"
            echo ""
            echo "  Then configure with:"
            echo "    export ARM_PREFIX=/opt/homebrew/opt/arm-gcc-bin@14/bin/arm-none-eabi-"
            ;;
        Linux)
            echo "  Ubuntu/Debian:"
            echo "    sudo apt-get install gcc-arm-none-eabi libnewlib-arm-none-eabi"
            echo ""
            echo "  Fedora/RHEL:"
            echo "    sudo dnf install arm-none-eabi-gcc-cs arm-none-eabi-newlib"
            echo ""
            echo "  Portable (no root required):"
            echo "    ./scripts/download-toolchain.sh"
            echo "    export ARM_PREFIX=\$HOME/arm-gnu-toolchain/bin/arm-none-eabi-"
            ;;
        *)
            echo "  Download from: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads"
            ;;
    esac

    echo ""
    exit 1
fi

echo -e "${GREEN}=== All required tools found ===${NC}"
echo ""
echo "Ready to build. Run:"
echo "  cmake --preset <platform>"
echo "  cmake --build --preset <platform>"
echo ""
exit 0
