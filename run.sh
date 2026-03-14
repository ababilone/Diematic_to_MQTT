#!/bin/sh
# ==============================================================================
# Diematic to MQTT – Home Assistant OS add-on entrypoint
# Reads /data/options.json (standard HA add-on location) with Python and
# generates Diematic32MQTT.conf, then launches the bridge.
# No bashio / HA base image required.
# ==============================================================================

set -e

# Generate config file from HA options (/data/options.json)
python3 - << 'PYEOF'
import json, os, sys

OPTIONS_FILE = '/data/options.json'

if not os.path.exists(OPTIONS_FILE):
    print(f'ERROR: {OPTIONS_FILE} not found – is this running as an HA add-on?', flush=True)
    sys.exit(1)

with open(OPTIONS_FILE) as f:
    o = json.load(f)

os.makedirs('/app/conf', exist_ok=True)

conf = f"""\
[Modbus]
connectionType: {o['connection_type']}
serialPort: {o['serial_port']}
baudrate: {o['serial_baudrate']}
ip: {o['tcp_ip']}
port: {o['tcp_port']}
regulatorAddress: {o['regulator_address']}
interfaceAddress: 0x32

[MQTT]
brokerHost: {o['mqtt_host']}
brokerPort: {o['mqtt_port']}
brokerLogin: {o.get('mqtt_login', '')}
brokerPassword: {o.get('mqtt_password', '')}
topicPrefix: {o['mqtt_topic_prefix']}
clientId: {o['mqtt_client_id']}

[Boiler]
regulatorType: {o['regulator_type']}
timezone: {o['timezone']}
timeSync: {o['time_sync']}
period: {o['period']}
enable_circuit_A: {o['enable_circuit_a']}
enable_circuit_B: {o['enable_circuit_b']}

[Home Assistant]
MQTT_DiscoveryEnable: {1 if o['ha_discovery_enable'] else 0}
discovery_prefix: {o['ha_discovery_prefix']}
"""

with open('/app/conf/Diematic32MQTT.conf', 'w') as f:
    f.write(conf)

print(f"Config generated (connection_type={o['connection_type']})", flush=True)

# Warn if serial device not present
if o['connection_type'] == 'serial' and not os.path.exists(o['serial_port']):
    print(f"WARNING: serial device {o['serial_port']} not found – check your USB adapter.", flush=True)
PYEOF

# Seed default logging config on first start
if [ ! -f /app/conf/logging.conf ]; then
    cp /app/conf_default/logging.conf /app/conf/logging.conf
fi

echo "Starting Diematic to MQTT bridge..."
cd /app
exec python3 Diematic32MQTT.py
