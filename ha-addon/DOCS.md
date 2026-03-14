# Diematic to MQTT – Home Assistant Add-on

Modbus bridge for De Dietrich boilers fitted with a **Diematic 3**, **Diematic 4**, or **Diematic Delta** regulator.

Boiler data is published to your MQTT broker and Home Assistant entities are automatically created via MQTT Discovery.

---

## Hardware requirements

The boiler exposes a **Modbus RTU RS485** port (Mini-DIN 4 connector). You need an adapter to connect it to your Home Assistant host:

| Adapter type | `connection_type` setting |
|---|---|
| USB RS485 dongle (e.g. CH340, FTDI) plugged into the HA host | `serial` |
| RS485-to-Ethernet/Wi-Fi module (e.g. USR-TCP232-306) | `tcp` |

### Wiring (boiler Mini-DIN 4)

```
Pin 1 (D+)  → RS485 A+
Pin 2 (D-)  → RS485 B-
Pin 3 (GND) → GND  (optional but recommended)
Pin 4       → not used
```

### Modbus parameters

| Parameter | Value |
|---|---|
| Mode | RTU (binary) |
| Baud rate | 9600 |
| Frame | 8N1 (8 bits, no parity, 1 stop bit) |
| Boiler address | `0x0A` (10) |

> **Note – dual-master timing**
> The Diematic 3 alternates between acting as Modbus master (5 s) and as Modbus slave (5 s). Response times are therefore 5–10 s and the `period` option should be set to at least 10 s.

---

## Installation

1. In Home Assistant go to **Settings → Add-ons → Add-on store → ⋮ → Repositories**.
2. Add the URL of this repository.
3. Install **Diematic to MQTT** from the store.
4. Configure the options (see below) and click **Start**.

---

## Configuration

### Connection (serial – USB RS485)

```yaml
connection_type: serial
serial_port: /dev/ttyUSB1   # adjust to your device
serial_baudrate: 9600
```

Tip: check **Settings → System → Hardware** in HA to find the correct device path.

### Connection (TCP – RS485-to-Ethernet)

```yaml
connection_type: tcp
tcp_ip: 192.168.1.X
tcp_port: 20108
```

### Boiler

| Option | Default | Description |
|---|---|---|
| `regulator_address` | `0x0A` | Modbus slave address of the boiler |
| `regulator_type` | `Diematic3` | `Diematic3`, `Diematic4`, or `DiematicDelta` |
| `timezone` | `Europe/Paris` | Boiler clock timezone (pytz name) |
| `time_sync` | `false` | Sync boiler clock to HA time automatically |
| `period` | `10` | Polling interval in seconds (minimum 10) |
| `enable_circuit_a` | `false` | Force zone A to be enabled (auto-detect otherwise) |
| `enable_circuit_b` | `false` | Force zone B to be enabled (auto-detect otherwise) |

### MQTT

| Option | Default | Description |
|---|---|---|
| `mqtt_host` | `core-mosquitto` | MQTT broker hostname or IP |
| `mqtt_port` | `1883` | MQTT broker port |
| `mqtt_login` | _(empty)_ | MQTT username (leave empty if not required) |
| `mqtt_password` | _(empty)_ | MQTT password |
| `mqtt_topic_prefix` | `home/heater` | Root MQTT topic |
| `mqtt_client_id` | `boiler` | Client ID appended to the topic prefix |

### Home Assistant discovery

| Option | Default | Description |
|---|---|---|
| `ha_discovery_enable` | `true` | Enable MQTT auto-discovery |
| `ha_discovery_prefix` | `homeassistant` | Discovery prefix (must match HA setting) |

---

## Entities created

Once started, the following entities appear automatically in Home Assistant:

**Sensors** – boiler temperature, return temperature, exhaust temperature, external temperature, zone A/B ambient temperature, hot-water temperature, water pressure, burner power, fan speed, ionisation current, pump power, alarm code.

**Binary sensors** – burner status, zone A pump, zone B pump, hot-water pump.

**Selects** – zone A mode, zone B mode, hot-water mode (AUTO / TEMP JOUR / PERM JOUR / TEMP NUIT / PERM NUIT / ANTIGEL).

**Numbers** – day/night/antifreeze setpoints for zone A, zone B, and hot water.

**Switch** – synchronise boiler clock to HA time.
