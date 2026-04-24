---
title: "Claude Code for STM32 Firmware"
description: "STM32 firmware development with Claude Code. Configure peripherals, write HAL drivers, and debug hard faults faster."
permalink: /claude-code-stm32-firmware-development-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for STM32 Firmware

STM32 firmware development means wrestling with 2,000-page reference manuals, cryptic register maps, and HAL/LL driver APIs that change between chip families. A single misconfigured clock tree or DMA channel can waste an entire day of debugging with a logic analyzer.

Claude Code reads your STM32CubeMX-generated initialization code, understands the HAL layer, and helps you write peripheral drivers that handle edge cases like DMA half-transfer interrupts, UART idle line detection, and flash write alignment. It knows the difference between STM32F4 and STM32H7 peripheral register layouts.

## The Workflow

### Step 1: Project Setup

```bash
# Install ARM toolchain and build system
brew install arm-none-eabi-gcc cmake  # macOS
# Or: sudo apt install gcc-arm-none-eabi cmake  # Ubuntu

# Install STM32CubeMX CLI (for code generation)
# Download from st.com, extract to ~/STM32CubeMX

# Install debugging tools
pip install pyocd
# Or use OpenOCD
brew install open-ocd

# PlatformIO alternative (simpler)
pip install platformio
pio init --board nucleo_f446re --project-dir firmware
```

### Step 2: Peripheral Driver with DMA

Claude Code generates HAL-based drivers that handle the tricky parts. Here is a UART driver with DMA and idle-line detection for variable-length packets:

```c
/* src/uart_dma.c — UART RX with DMA + idle line detection */
#include "stm32f4xx_hal.h"
#include <string.h>
#include <assert.h>

#define UART_RX_BUF_SIZE 256
#define UART_MAX_PACKET  128

typedef struct {
    UART_HandleTypeDef *huart;
    DMA_HandleTypeDef  *hdma_rx;
    uint8_t             rx_buf[UART_RX_BUF_SIZE];
    uint8_t             packet_buf[UART_MAX_PACKET];
    volatile uint16_t   packet_len;
    volatile uint8_t    packet_ready;
} uart_dma_ctx_t;

static uart_dma_ctx_t ctx;

/**
 * Initialize UART with DMA circular mode and IDLE interrupt.
 */
void uart_dma_init(UART_HandleTypeDef *huart, DMA_HandleTypeDef *hdma)
{
    assert(huart != NULL);
    assert(hdma != NULL);

    ctx.huart = huart;
    ctx.hdma_rx = hdma;
    ctx.packet_len = 0;
    ctx.packet_ready = 0;

    memset(ctx.rx_buf, 0, UART_RX_BUF_SIZE);

    /* Start DMA in circular mode */
    HAL_StatusTypeDef status = HAL_UART_Receive_DMA(huart,
        ctx.rx_buf, UART_RX_BUF_SIZE);
    assert(status == HAL_OK);

    /* Enable IDLE line interrupt */
    __HAL_UART_ENABLE_IT(huart, UART_IT_IDLE);
}

/**
 * Call from USARTx_IRQHandler when IDLE flag is set.
 * Calculates received byte count from DMA NDTR register.
 */
void uart_dma_idle_handler(void)
{
    if (__HAL_UART_GET_FLAG(ctx.huart, UART_FLAG_IDLE)) {
        __HAL_UART_CLEAR_IDLEFLAG(ctx.huart);

        uint16_t dma_remaining = __HAL_DMA_GET_COUNTER(ctx.hdma_rx);
        uint16_t received = UART_RX_BUF_SIZE - dma_remaining;

        assert(received <= UART_RX_BUF_SIZE);

        if (received > 0 && received <= UART_MAX_PACKET) {
            memcpy(ctx.packet_buf, ctx.rx_buf, received);
            ctx.packet_len = received;
            ctx.packet_ready = 1;
        }

        /* Restart DMA for next packet */
        HAL_UART_AbortReceive(ctx.huart);
        HAL_UART_Receive_DMA(ctx.huart,
            ctx.rx_buf, UART_RX_BUF_SIZE);
    }
}

/**
 * Poll for received packet. Non-blocking.
 * Returns packet length, 0 if no packet ready.
 */
uint16_t uart_dma_get_packet(uint8_t *dest, uint16_t max_len)
{
    assert(dest != NULL);
    assert(max_len > 0);

    if (!ctx.packet_ready) {
        return 0;
    }

    uint16_t copy_len = (ctx.packet_len < max_len)
                        ? ctx.packet_len : max_len;
    memcpy(dest, ctx.packet_buf, copy_len);
    ctx.packet_ready = 0;

    return copy_len;
}
```

### Step 3: Build and Flash

```bash
# CMake build
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/arm-gcc-toolchain.cmake ..
make -j$(nproc)

# Flash via OpenOCD
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "program firmware.elf verify reset exit"

# Or PlatformIO
pio run --target upload

# Debug with GDB
arm-none-eabi-gdb firmware.elf \
  -ex "target remote :3333" \
  -ex "monitor reset halt" \
  -ex "break main" -ex "continue"
# Expected: breakpoint at main(), peripheral registers accessible
```

## CLAUDE.md for STM32 Firmware

```markdown
# STM32 Firmware Rules

## Standards
- MISRA C:2012 (automotive/safety critical)
- BARR-C:2018 coding standard
- ARM CMSIS 5.x headers

## File Formats
- .c / .h for source (C11, no C++)
- .ld for linker scripts
- .ioc for STM32CubeMX project
- .elf / .bin / .hex for firmware images

## Libraries
- STM32 HAL v1.8+ (F4) or v1.12+ (H7)
- FreeRTOS v10.6+ (when using RTOS)
- CMSIS-DSP (for signal processing)
- lwIP 2.2+ (for Ethernet-capable chips)

## Testing
- Unity test framework for host-side unit tests
- Hardware-in-the-loop via pyOCD + pytest
- Static analysis: cppcheck --enable=all --std=c11

## Rules
- All functions must check HAL return status
- ISR handlers must be <50 lines, defer work to task
- No malloc in production firmware — static allocation only
- Every DMA transfer must have completion callback
```

## Common Pitfalls

- **Clock tree misconfiguration:** Running peripherals on the wrong bus clock causes silent data corruption. Claude Code checks your SystemClock_Config against the reference manual clock tree diagram for your specific chip variant.
- **DMA and cache coherency on STM32H7:** The H7 series has separate D-cache that is not coherent with DMA. Claude Code adds the necessary SCB_CleanDCache_by_Addr/SCB_InvalidateDCache_by_Addr calls around DMA buffers.
- **Hard fault with no stack trace:** A misconfigured MPU or stack overflow causes a hard fault with useless registers. Claude Code generates a HardFault_Handler that extracts the stacked PC and LR for postmortem analysis.

## Related

- [Claude Code for Embedded Systems](/claude-skills-for-embedded-systems-iot-firmware/)
- [Claude Code for FPGA Development](/claude-code-for-fpga-development-workflow-tutorial/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for 3D Printer Firmware (2026)](/claude-code-3d-printer-firmware-customization-2026/)
- [Claude Code for ESP32 Firmware with ESP-IDF (2026)](/claude-code-esp32-firmware-development-2026/)
- [Claude Code for Medical Device IEC 62304 (2026)](/claude-code-medical-device-firmware-iec62304-2026/)
