# Pinata Firmware Development Container
# Provides ARM Cortex-M4 cross-compilation toolchain and debugging tools

FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

LABEL maintainer="sealablab"
LABEL description="Development environment for Pinata SCA/FI training firmware"

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools, ARM toolchain, and debugging utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    cmake \
    ninja-build \
    # ARM cross-compilation toolchain
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    # Debugging tools
    gdb-multiarch \
    openocd \
    # Flashing utility
    dfu-util \
    # Test dependencies (for PinataTests)
    libboost-dev \
    libssl-dev \
    libgtest-dev \
    # Useful utilities
    python3 \
    python3-pip \
    picocom \
    screen \
    usbutils \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic link for gdb to work with ARM targets
RUN ln -sf /usr/bin/gdb-multiarch /usr/bin/arm-none-eabi-gdb

# Set up udev rules for STM32 DFU mode and Tigard (for when USB passthrough is available)
RUN mkdir -p /etc/udev/rules.d && \
    # STM32 DFU mode
    echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/69-pinata.rules && \
    # Tigard FTDI FT2232H (VID:PID 0403:6010)
    echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666", GROUP="plugdev"' >> /etc/udev/rules.d/69-pinata.rules

# Add vscode user to plugdev and dialout groups for device access
RUN usermod -aG plugdev,dialout vscode

# Set working directory
WORKDIR /workspaces

# Default command
CMD ["bash"]
