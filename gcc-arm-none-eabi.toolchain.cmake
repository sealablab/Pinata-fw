# Toolchain for gcc-arm-none-eabi
#
# Set PREFIX to the toolchain prefix, e.g.:
#   -DPREFIX=/opt/homebrew/opt/arm-gcc-bin@14/bin/arm-none-eabi-
#
# Or set ARM_TOOLCHAIN_DIR environment variable to the toolchain root:
#   export ARM_TOOLCHAIN_DIR=$HOME/arm-gnu-toolchain

# Try to find toolchain prefix
if(NOT DEFINED PREFIX)
    # Check ARM_TOOLCHAIN_DIR environment variable
    if(DEFINED ENV{ARM_TOOLCHAIN_DIR})
        set(PREFIX "$ENV{ARM_TOOLCHAIN_DIR}/bin/arm-none-eabi-")
        message(STATUS "Using ARM_TOOLCHAIN_DIR: $ENV{ARM_TOOLCHAIN_DIR}")
    # Check ARM_PREFIX environment variable
    elseif(DEFINED ENV{ARM_PREFIX})
        set(PREFIX "$ENV{ARM_PREFIX}")
        message(STATUS "Using ARM_PREFIX: $ENV{ARM_PREFIX}")
    # Platform-specific defaults
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        # macOS: Check Homebrew locations
        if(EXISTS "/opt/homebrew/opt/arm-gcc-bin@14/bin/arm-none-eabi-gcc")
            set(PREFIX "/opt/homebrew/opt/arm-gcc-bin@14/bin/arm-none-eabi-")
        elseif(EXISTS "/usr/local/opt/arm-gcc-bin@14/bin/arm-none-eabi-gcc")
            set(PREFIX "/usr/local/opt/arm-gcc-bin@14/bin/arm-none-eabi-")
        else()
            set(PREFIX "/usr/bin/arm-none-eabi-")
        endif()
    else()
        # Linux/other: Check common locations
        if(EXISTS "$ENV{HOME}/arm-gnu-toolchain/bin/arm-none-eabi-gcc")
            set(PREFIX "$ENV{HOME}/arm-gnu-toolchain/bin/arm-none-eabi-")
        else()
            set(PREFIX "/usr/bin/arm-none-eabi-")
        endif()
    endif()
    message(STATUS "Using toolchain prefix: ${PREFIX}")
endif()

# Validate toolchain exists
if(NOT EXISTS "${PREFIX}gcc")
    message(FATAL_ERROR
        "ARM toolchain not found at: ${PREFIX}gcc\n"
        "\n"
        "The ARM cross-compiler (arm-none-eabi-gcc) is required.\n"
        "\n"
        "Installation options:\n"
        "\n"
        "  macOS (Homebrew):\n"
        "    brew tap osx-cross/arm && brew install arm-gcc-bin@14\n"
        "\n"
        "  Ubuntu/Debian:\n"
        "    sudo apt-get install gcc-arm-none-eabi libnewlib-arm-none-eabi\n"
        "\n"
        "  Portable (any platform):\n"
        "    ./scripts/download-toolchain.sh\n"
        "    export ARM_TOOLCHAIN_DIR=$HOME/arm-gnu-toolchain\n"
        "\n"
        "Then reconfigure with:\n"
        "    cmake --preset <platform>\n"
        "\n"
        "Or specify the prefix directly:\n"
        "    cmake -DPREFIX=/path/to/arm-none-eabi- ...\n"
    )
endif()

set(CMAKE_C_COMPILER ${PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${PREFIX}g++)
set(CMAKE_ASM_COMPILER ${PREFIX}gcc)
set(CMAKE_OBJCOPY ${PREFIX}objcopy)
set(CMAKE_NM ${PREFIX}nm)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Compiler flags
set(CMAKE_C_FLAGS_INIT "-mcpu=cortex-m4 -mfloat-abi=softfp -mthumb -mfpu=fpv4-sp-d16 -ffunction-sections -fdata-sections")
set(CMAKE_ASM_FLAGS_INIT ${CMAKE_C_FLAGS_INIT})
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_C_FLAGS_INIT}" CACHE STRING "" FORCE)

# Linker flags
set(CMAKE_EXE_LINKER_FLAGS_INIT "-nostartfiles -Wl,--gc-sections -T${CMAKE_CURRENT_SOURCE_DIR}/arm-gcc-link.ld")
