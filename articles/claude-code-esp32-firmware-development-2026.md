---
layout: default
title: "Claude Code for ESP32 Firmware (2026)"
description: "Claude Code for ESP32 Firmware — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-esp32-firmware-development-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for ESP32 Firmware

The ESP32 ecosystem has exploded: ESP32-S3, ESP32-C3, ESP32-C6 each have different peripheral sets, and ESP-IDF (the official framework) moves fast with breaking API changes between major versions. Building a production firmware that combines WiFi provisioning, BLE GATT services, deep sleep power management, and OTA updates requires stitching together dozens of ESP-IDF components with correct Kconfig settings.

Claude Code understands ESP-IDF's component architecture, FreeRTOS task model, and the menuconfig system. It generates firmware code that handles WiFi reconnection, BLE advertisement, NVS (non-volatile storage) for credentials, and the partition table layout needed for OTA-capable firmware.

## The Workflow

### Step 1: Environment Setup

```bash
# Install ESP-IDF v5.x
mkdir -p ~/esp && cd ~/esp
git clone --recursive https://github.com/espressif/esp-idf.git -b v5.3
cd esp-idf && ./install.sh esp32,esp32s3,esp32c3
source export.sh

# Create project
idf.py create-project --path ~/esp/my_sensor sensor_firmware
cd ~/esp/my_sensor
```

### Step 2: BLE Sensor Firmware with Deep Sleep

```c
/* main/sensor_firmware.c — ESP32 BLE sensor with deep sleep */
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "esp_sleep.h"
#include "nvs_flash.h"
#include "esp_bt.h"
#include "esp_gap_ble_api.h"
#include "esp_gatts_api.h"
#include "esp_bt_main.h"
#include "driver/adc.h"
#include "esp_adc_cal.h"

#define TAG "SENSOR"
#define DEEP_SLEEP_DURATION_US  (30 * 1000000)  /* 30 seconds */
#define ADC_CHANNEL             ADC1_CHANNEL_6   /* GPIO34 */
#define GATTS_SERVICE_UUID      0x181A           /* Environmental Sensing */
#define GATTS_CHAR_UUID_TEMP    0x2A6E           /* Temperature */
#define MAX_SENSOR_VALUE        10000
#define MIN_SENSOR_VALUE        -4000
#define STACK_SIZE              4096
#define BLE_ADV_TIMEOUT_S       10

static uint16_t gatts_handle_table[3];
static int16_t current_temperature = 0;

/**
 * Read temperature from ADC (NTC thermistor).
 * Returns temperature in 0.01 degree C units.
 */
static int16_t read_temperature(void)
{
    int raw = adc1_get_raw(ADC_CHANNEL);
    assert(raw >= 0 && raw <= 4095);

    /* NTC thermistor lookup (simplified Steinhart-Hart) */
    float voltage = (float)raw / 4095.0f * 3.3f;
    float resistance = (3.3f - voltage) / voltage * 10000.0f;
    assert(resistance > 0);

    float temp_k = 1.0f / (
        1.0f / 298.15f +
        (1.0f / 3950.0f) * logf(resistance / 10000.0f));
    int16_t temp_c = (int16_t)((temp_k - 273.15f) * 100.0f);

    assert(temp_c >= MIN_SENSOR_VALUE && temp_c <= MAX_SENSOR_VALUE);
    return temp_c;
}

/**
 * GATT server event handler.
 */
static void gatts_event_handler(esp_gatts_cb_event_t event,
                                 esp_gatt_if_t gatts_if,
                                 esp_ble_gatts_cb_param_t *param)
{
    assert(param != NULL);

    switch (event) {
    case ESP_GATTS_REG_EVT:
        ESP_LOGI(TAG, "GATT service registered");
        break;

    case ESP_GATTS_READ_EVT:
        if (param->read.handle == gatts_handle_table[1]) {
            current_temperature = read_temperature();
            esp_gatt_rsp_t rsp = {0};
            rsp.attr_value.len = sizeof(int16_t);
            memcpy(rsp.attr_value.value, &current_temperature,
                   sizeof(int16_t));
            esp_ble_gatts_send_response(
                gatts_if, param->read.conn_id,
                param->read.trans_id,
                ESP_GATT_OK, &rsp);
            ESP_LOGI(TAG, "Temperature read: %d.%02d C",
                     current_temperature / 100,
                     abs(current_temperature % 100));
        }
        break;

    case ESP_GATTS_CONNECT_EVT:
        ESP_LOGI(TAG, "Client connected");
        break;

    case ESP_GATTS_DISCONNECT_EVT:
        ESP_LOGI(TAG, "Client disconnected — entering deep sleep");
        esp_deep_sleep(DEEP_SLEEP_DURATION_US);
        break;

    default:
        break;
    }
}

/**
 * Initialize NVS, BLE, and start GATT server.
 */
static void init_ble(void)
{
    esp_err_t ret;

    ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES ||
        ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT));

    esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_bt_controller_init(&bt_cfg));
    ESP_ERROR_CHECK(esp_bt_controller_enable(ESP_BT_MODE_BLE));
    ESP_ERROR_CHECK(esp_bluedroid_init());
    ESP_ERROR_CHECK(esp_bluedroid_enable());

    ESP_ERROR_CHECK(esp_ble_gatts_register_callback(gatts_event_handler));
    ESP_ERROR_CHECK(esp_ble_gatts_app_register(0));

    ESP_LOGI(TAG, "BLE initialized");
}

void app_main(void)
{
    ESP_LOGI(TAG, "Sensor firmware starting");

    /* Configure ADC */
    adc1_config_width(ADC_WIDTH_BIT_12);
    adc1_config_channel_atten(ADC_CHANNEL, ADC_ATTEN_DB_11);

    /* Check wake reason */
    esp_sleep_wakeup_cause_t cause = esp_sleep_get_wakeup_cause();
    if (cause == ESP_SLEEP_WAKEUP_TIMER) {
        ESP_LOGI(TAG, "Woke from deep sleep (timer)");
    }

    init_ble();

    /* If no BLE connection within timeout, sleep to save power */
    vTaskDelay(pdMS_TO_TICKS(BLE_ADV_TIMEOUT_S * 1000));
    ESP_LOGI(TAG, "No connection — entering deep sleep");
    esp_deep_sleep(DEEP_SLEEP_DURATION_US);
}
```

### Step 3: Build, Flash, and Monitor

```bash
# Configure target chip
idf.py set-target esp32s3

# Build
idf.py build
# Expected: binary size < 1MB, no warnings

# Flash and monitor
idf.py -p /dev/ttyUSB0 flash monitor
# Expected: "BLE initialized" followed by temperature readings
# Use nRF Connect app to read temperature characteristic

# Check partition table for OTA readiness
idf.py partition-table
```

## CLAUDE.md for ESP32 Firmware

```markdown
# ESP32 Firmware Rules

## Standards
- ESP-IDF v5.x API
- FreeRTOS task model (configMAX_PRIORITIES = 25)
- BLE: Bluetooth SIG GATT specification

## File Formats
- .c / .h (C11 source)
- .csv (partition table)
- Kconfig / sdkconfig (build configuration)
- CMakeLists.txt (ESP-IDF build system)

## Libraries
- ESP-IDF v5.3+
- FreeRTOS 10.x (built into ESP-IDF)
- esp_wifi, esp_bt (connectivity)
- driver/ (GPIO, ADC, SPI, I2C, UART)

## Testing
- Unit tests via ESP-IDF test runner (Unity framework)
- Integration: flash to dev board + monitor output
- Power consumption: measure with multimeter in deep sleep

## Rules
- All ESP_ERROR_CHECK on API returns
- Tasks: stack size >= 4096, no dynamic allocation in ISR
- NVS: always handle ESP_ERR_NVS_NO_FREE_PAGES
- OTA: dual partition scheme (factory + ota_0 + ota_1)
- Deep sleep: configure wake sources before entering sleep
```

## Common Pitfalls

- **WiFi and BLE coexistence crashes:** Running WiFi and BLE simultaneously on ESP32 (not S3/C3) requires careful memory management and coexistence configuration. Claude Code enables Bluetooth modem sleep and sets correct sdkconfig options.
- **Brown-out reset in deep sleep wake:** Peripherals drawing current during the brief wake period cause VDD to dip below the brown-out threshold. Claude Code delays peripheral initialization until after the power supply stabilizes.
- **NVS corruption on power loss:** Writing to NVS during a power loss corrupts the partition. Claude Code uses NVS commit only after all writes are buffered and adds error recovery on init.



**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for STM32 Firmware](/claude-code-stm32-firmware-development-2026/)
- [Claude Code for Embedded Systems](/claude-skills-for-embedded-systems-iot-firmware/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for 3D Printer Firmware (2026)](/claude-code-3d-printer-firmware-customization-2026/)
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
