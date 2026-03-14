<h2>MQTT interface for De Dietrich boilers with Diematic 3 / 4 / Delta regulator</h2>

Control and monitor your De Dietrich boiler through MQTT using a Raspberry Pi (or any Linux host running Home Assistant OS).

> **This is a fork of [Benoit3/Diematic_to_MQTT](https://github.com/Benoit3/Diematic_to_MQTT)** with two major additions:
> 1. **USB RS485 serial transport** – connect a cheap USB RS485 dongle directly to your HA host without a network adapter.
> 2. **Home Assistant OS native add-on** – install and configure everything from the HA UI without touching the command line.

---

<h2>Hardware</h2>

The Diematic 3 regulator exposes a **Modbus RTU RS485** port (Mini-DIN 4).

| Adapter | Config |
|---|---|
| USB RS485 dongle (CH340, FTDI, …) | `connectionType: serial` |
| RS485-to-Ethernet/Wi-Fi (USR-TCP232-306, …) | `connectionType: tcp` |

### Wiring (Mini-DIN 4)

![ModBus wiring](ReadMeImages/ModBusMiniDinConnection.png)

```
Pin 1 (D+)  → RS485 A+
Pin 2 (D-)  → RS485 B-
Pin 3 (GND) → GND  (optional but recommended)
```

### Modbus parameters

| Parameter | Value |
|---|---|
| Mode | RTU (binary) |
| Baud rate | 9600 |
| Frame | 8N1 |
| Boiler address | `0x0A` (10 decimal) |

> **Dual-master timing** – The Diematic 3 alternates between acting as Modbus master (5 s) and slave (5 s). Response times are therefore 5–10 s; keep `period` ≥ 10 s.

---

<h2>Installation</h2>

<h3>Option A – Home Assistant OS Add-on (recommended)</h3>

1. In Home Assistant go to **Settings → Add-ons → Add-on store → ⋮ → Repositories**.
2. Add the URL of this repository.
3. Install **Diematic to MQTT** from the list.
4. Fill in the options (see `ha-addon/DOCS.md` or the HA UI info tab) and click **Start**.

The add-on generates its own configuration file from the HA options and runs the Python bridge in an isolated container.
Serial (`/dev/ttyUSB*`) and UART devices are automatically exposed to the container via the `uart: true` flag.

<h3>Option B – Docker (standalone)</h3>

```bash
docker run -d \
  --device /dev/ttyUSB1 \
  -v $(pwd)/src/conf:/app/conf \
  ghcr.io/ababilone/diematic_to_mqtt:latest
```

Edit `src/conf/Diematic32MQTT.conf` before starting (see configuration below).

<h3>Option C – Python directly (Raspberry Pi / Raspbian)</h3>

```bash
pip3 install -r src/requirements.txt
cd src
python3 Diematic32MQTT.py
```

See the [Wiki](https://github.com/Benoit3/Diematic_to_MQTT/wiki) for the systemd service setup.

---

<h2>Configuration (Diematic32MQTT.conf)</h2>

```ini
[Modbus]
# connectionType: serial  → USB RS485 adapter
# connectionType: tcp     → RS485-to-Ethernet adapter (original)
connectionType: serial

# Serial mode
serialPort: /dev/ttyUSB1
baudrate: 9600

# TCP mode (used when connectionType = tcp)
ip: 192.168.1.X
port: 20108

regulatorAddress: 0x0A
interfaceAddress: 0x32

[MQTT]
brokerHost: localhost
brokerPort: 1883
brokerLogin:
brokerPassword:
topicPrefix: home/heater
clientId: boiler

[Boiler]
regulatorType: Diematic3   # Diematic3 | Diematic4 | DiematicDelta
timezone: Europe/Paris
timeSync: False
period: 10
enable_circuit_A: False
enable_circuit_B: False

[Home Assistant]
MQTT_DiscoveryEnable: 1
discovery_prefix: homeassistant
```

---

<h2>Home Assistant Integration</h2>

MQTT discovery is enabled by default. Once the bridge is running, the following entities appear automatically:

**Sensors** – boiler temperature, return temperature, exhaust temperature, external temperature, zone A/B ambient temperature, ECS temperature, water pressure, burner power, fan speed, ionisation current, pump power, alarm.

**Binary sensors** – burner status, zone A/B pump, hot-water pump.

**Selects (control)** – zone A mode, zone B mode, hot-water mode.

**Numbers (control)** – day/night/antifreeze setpoints for zone A, zone B, and hot water.

**Switch** – sync boiler clock to HA time.

![Hassio_Control](ReadMeImages/HassioControlCard.png) ![Hassio_Control](ReadMeImages/HassioMonitoringCard.png)
![Hassio_Control](ReadMeImages/HassioSettingCard.png)

Make sure your MQTT integration birth-message topic is `homeassistant/status` with payload `online` for discovery to work after a restart.

---

<h2>Known limitations</h2>

- Remote display heating mode not updatable without a workaround.
- No support for switching between programs (P1–P4).
- ECS pump info not fully reliable.
- Permanent antifreeze mode replaces temporary antifreeze (hardware limitation).
- Pump power stays at 100 % when all pumps are off.

---

<h2>References</h2>

- Original project: [Benoit3/Diematic_to_MQTT](https://github.com/Benoit3/Diematic_to_MQTT)
- [Home Assistant Community thread](https://community.home-assistant.io/t/de-dietrich-diematic-modbus-to-mqtt-interface/363086)
- [Fibaro forum (French)](https://www.domotique-fibaro.fr/topic/5677-de-dietrich-diematic-isystem/)
