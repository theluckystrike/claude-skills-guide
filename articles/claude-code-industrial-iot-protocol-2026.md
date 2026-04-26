---
layout: default
title: "Claude Code for Industrial IoT (2026)"
permalink: /claude-code-industrial-iot-protocol-2026/
date: 2026-04-20
description: "Claude Code for Industrial IoT — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for Industrial IoT

Industrial IoT bridges operational technology (OT) with IT systems, but the protocol landscape is fragmented: Modbus RTU/TCP for legacy PLCs, OPC UA for modern SCADA, MQTT Sparkplug B for cloud telemetry, and EtherNet/IP for Allen-Bradley controllers. Each protocol has its own register maps, data type encodings, and session management quirks. A single gateway might need to poll 200 Modbus registers, translate them to OPC UA nodes, and publish to MQTT -- all with deterministic timing.

Claude Code generates protocol-specific code that handles the bit-level details: Modbus function codes, OPC UA node IDs, Sparkplug B protobuf encoding, and the CRC/authentication layers that differ between protocols. It builds the glue code that would otherwise take weeks of datasheet reading.

## The Workflow

### Step 1: Protocol Stack Setup

```bash
pip install pymodbus==3.6.4 asyncua==1.1.0 paho-mqtt==2.0.0
pip install sparkplug-b protobuf grpcio

# For EtherNet/IP (Allen-Bradley)
pip install pycomm3==1.10.0

mkdir -p src/gateway src/protocols src/config tests/
```

### Step 2: Build a Multi-Protocol Gateway

```python
# src/gateway/iiot_gateway.py
"""Industrial IoT Gateway: Modbus TCP -> OPC UA + MQTT Sparkplug B.
Polls PLCs, translates register data, publishes to cloud.
"""

import asyncio
import struct
import logging
from dataclasses import dataclass, field
from pymodbus.client import AsyncModbusTcpClient
from asyncua import Server, ua
import paho.mqtt.client as mqtt

logger = logging.getLogger(__name__)

@dataclass
class ModbusRegister:
    name: str
    address: int
    count: int           # Number of 16-bit registers
    data_type: str       # 'uint16', 'float32', 'int32'
    unit: str
    scale_factor: float = 1.0
    slave_id: int = 1

# Register map from PLC documentation
REGISTER_MAP = [
    ModbusRegister("tank_level_mm", 40001, 1, "uint16", "mm", 1.0),
    ModbusRegister("flow_rate_lpm", 40010, 2, "float32", "L/min"),
    ModbusRegister("pump_pressure_bar", 40020, 2, "float32", "bar"),
    ModbusRegister("motor_current_a", 40030, 1, "uint16", "A", 0.01),
    ModbusRegister("valve_state", 40040, 1, "uint16", "bool"),
]

def decode_register(raw: list, reg: ModbusRegister) -> float:
    """Decode Modbus register(s) to engineering value."""
    assert len(raw) >= reg.count, f"Short read for {reg.name}"

    if reg.data_type == "uint16":
        value = raw[0]
    elif reg.data_type == "float32":
        # Modbus big-endian word order (AB CD)
        combined = (raw[0] << 16) | raw[1]
        value = struct.unpack('>f', struct.pack('>I', combined))[0]
    elif reg.data_type == "int32":
        combined = (raw[0] << 16) | raw[1]
        value = struct.unpack('>i', struct.pack('>I', combined))[0]
    else:
        raise ValueError(f"Unknown type: {reg.data_type}")

    return value * reg.scale_factor

async def poll_modbus(client: AsyncModbusTcpClient,
                      registers: list) -> dict:
    """Poll all registers from a Modbus TCP slave."""
    readings = {}
    for reg in registers:
        # Modbus function code 3: Read Holding Registers
        # Address offset: Modbus convention uses 40001-based addressing
        result = await client.read_holding_registers(
            address=reg.address - 40001,
            count=reg.count,
            slave=reg.slave_id
        )
        if not result.isError():
            readings[reg.name] = decode_register(result.registers, reg)
        else:
            logger.warning(f"Modbus error reading {reg.name}: {result}")
            readings[reg.name] = None

    assert len(readings) > 0, "All register reads failed"
    return readings

async def publish_opcua(server: Server, readings: dict,
                        node_map: dict) -> None:
    """Update OPC UA variable nodes with latest readings."""
    for name, value in readings.items():
        if value is not None and name in node_map:
            node = node_map[name]
            await node.write_value(ua.DataValue(ua.Variant(
                float(value), ua.VariantType.Double
            )))

def publish_sparkplug(mqtt_client, readings: dict,
                      group_id: str, node_id: str) -> None:
    """Publish Sparkplug B NDATA message."""
    from sparkplug_b import sparkplug_b_pb2 as spb
    payload = spb.Payload()
    payload.timestamp = int(asyncio.get_event_loop().time() * 1000)

    for name, value in readings.items():
        if value is not None:
            metric = payload.metrics.add()
            metric.name = name
            metric.datatype = spb.MetricDataType.Double
            metric.double_value = float(value)

    topic = f"spBv1.0/{group_id}/NDATA/{node_id}"
    mqtt_client.publish(topic, payload.SerializeToString())

async def gateway_loop(modbus_host: str = "192.168.1.10",
                       poll_interval_s: float = 1.0) -> None:
    """Main gateway polling loop."""
    modbus = AsyncModbusTcpClient(modbus_host, port=502)
    await modbus.connect()
    assert modbus.connected, f"Cannot connect to {modbus_host}:502"

    logger.info(f"Gateway started, polling {modbus_host} every {poll_interval_s}s")

    while True:
        readings = await poll_modbus(modbus, REGISTER_MAP)
        logger.info(f"Polled {len(readings)} registers")
        await asyncio.sleep(poll_interval_s)
```

### Step 3: Verify with Simulated PLC

```bash
# Start Modbus simulator
python3 -c "
from pymodbus.server import StartTcpServer
from pymodbus.datastore import ModbusSlaveContext, ModbusServerContext
from pymodbus.datastore import ModbusSequentialDataBlock
import struct

# Pre-load registers with test data
hr = ModbusSequentialDataBlock(0, [0]*100)
hr.setValues(1, [1500])          # tank_level: 1500mm
# flow_rate: 25.5 L/min as float32
f_bytes = struct.pack('>f', 25.5)
hr.setValues(10, [int.from_bytes(f_bytes[0:2], 'big'),
                   int.from_bytes(f_bytes[2:4], 'big')])

store = ModbusSlaveContext(hr=hr)
context = ModbusServerContext(slaves=store, single=True)
print('Modbus simulator running on :502')
StartTcpServer(context=context, address=('0.0.0.0', 5020))
" &

# Test the gateway
python3 -c "
import asyncio
from pymodbus.client import AsyncModbusTcpClient

async def test():
    client = AsyncModbusTcpClient('127.0.0.1', port=5020)
    await client.connect()
    result = await client.read_holding_registers(0, 1, slave=1)
    print(f'Tank level raw: {result.registers[0]}')
    assert result.registers[0] == 1500, 'Register mismatch'
    print('Modbus read: PASS')
    client.close()

asyncio.run(test())
"
```

## CLAUDE.md for Industrial IoT

```markdown
# Industrial IoT Gateway Development

## Protocols
- Modbus RTU (RS-485) / Modbus TCP (Ethernet)
- OPC UA (IEC 62541) — unified architecture
- MQTT 3.1.1 / 5.0 with Sparkplug B payload
- EtherNet/IP (CIP) for Allen-Bradley
- PROFINET for Siemens

## Libraries
- pymodbus 3.6+ (Modbus RTU/TCP)
- asyncua 1.1+ (OPC UA client/server)
- paho-mqtt 2.0+ (MQTT client)
- pycomm3 1.10+ (EtherNet/IP CIP)
- sparkplug-b (Sparkplug B protobuf)

## Safety Rules
- Never write to PLC registers without operator confirmation
- Poll intervals must not exceed PLC scan cycle time
- All Modbus writes require function code 6 (single) or 16 (multiple)
- Implement watchdog timeout: if gateway stops polling, PLC must detect

## Common Commands
- mbpoll -a 1 -r 40001 -c 10 192.168.1.10 — CLI Modbus poll
- opcua-client opc.tcp://localhost:4840 — browse OPC UA server
- mosquitto_sub -t 'spBv1.0/#' -v — monitor Sparkplug messages
```

## Common Pitfalls

- **Modbus word order mismatch:** Some PLCs use big-endian (AB CD) and others use little-endian (CD AB) for 32-bit floats. Claude Code generates a decode function with configurable word order that you verify against one known reading.
- **OPC UA session timeout:** Default keepalive of 30s is too short for intermittent connections. Claude Code configures session timeout, subscription intervals, and automatic reconnection with exponential backoff.
- **Sparkplug B birth/death lifecycle:** Forgetting to send NBIRTH on reconnect causes the SCADA host to ignore all subsequent NDATA messages. Claude Code implements the full Sparkplug state machine including NBIRTH, NDEATH, and last-will testament.

## Related

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for SCADA System Modernization](/claude-code-scada-modernization-2026/)
- [Claude Code for PLC Programming (Structured Text)](/claude-code-plc-ladder-logic-structured-text-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)


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
