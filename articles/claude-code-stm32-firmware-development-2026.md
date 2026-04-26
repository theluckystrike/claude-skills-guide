---
layout: default
title: "Claude Code for STM32 Firmware (2026)"
description: "Claude Code for STM32 Firmware — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-stm32-firmware-development-2026/
date: 2026-04-20
last_tested: "2026-04-21"
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



**Get started →** Generate your project setup with our [Project Starter](/starter/).

## Related

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Embedded Systems](/claude-skills-for-embedded-systems-iot-firmware/)
- [Claude Code for FPGA Development](/claude-code-for-fpga-development-workflow-tutorial/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for 3D Printer Firmware (2026)](/claude-code-3d-printer-firmware-customization-2026/)
- [Claude Code for ESP32 Firmware with ESP-IDF (2026)](/claude-code-esp32-firmware-development-2026/)
- [Claude Code for Medical Device IEC 62304 (2026)](/claude-code-medical-device-firmware-iec62304-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.



## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
