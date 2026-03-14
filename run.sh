#!/usr/bin/with-contenv bashio
# ==============================================================================
# Diematic to MQTT – Home Assistant OS add-on entrypoint
# Reads options from /data/options.json (via bashio) and generates the
# Diematic32MQTT.conf before launching the Python script.
# ==============================================================================

# --------------------------------------------------------------------------
# Read user options
# --------------------------------------------------------------------------
CONNECTION_TYPE=$(bashio::config 'connection_type')
SERIAL_PORT=$(bashio::config 'serial_port')
SERIAL_BAUDRATE=$(bashio::config 'serial_baudrate')
TCP_IP=$(bashio::config 'tcp_ip')
TCP_PORT=$(bashio::config 'tcp_port')

REGULATOR_ADDRESS=$(bashio::config 'regulator_address')
REGULATOR_TYPE=$(bashio::config 'regulator_type')
TIMEZONE=$(bashio::config 'timezone')
TIME_SYNC=$(bashio::config 'time_sync')
PERIOD=$(bashio::config 'period')
ENABLE_CIRCUIT_A=$(bashio::config 'enable_circuit_a')
ENABLE_CIRCUIT_B=$(bashio::config 'enable_circuit_b')

MQTT_HOST=$(bashio::config 'mqtt_host')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_LOGIN=$(bashio::config 'mqtt_login')
MQTT_PASSWORD=$(bashio::config 'mqtt_password')
MQTT_TOPIC_PREFIX=$(bashio::config 'mqtt_topic_prefix')
MQTT_CLIENT_ID=$(bashio::config 'mqtt_client_id')

HA_DISCOVERY=$(bashio::config 'ha_discovery_enable')
HA_DISCOVERY_PREFIX=$(bashio::config 'ha_discovery_prefix')

# --------------------------------------------------------------------------
# Validate serial device when connection_type = serial
# --------------------------------------------------------------------------
if [ "${CONNECTION_TYPE}" = "serial" ]; then
    if [ ! -e "${SERIAL_PORT}" ]; then
        bashio::log.warning "Serial device ${SERIAL_PORT} not found."
        bashio::log.warning "Make sure the USB RS485 adapter is plugged in and the port is correct."
    else
        bashio::log.info "Serial device ${SERIAL_PORT} found."
    fi
fi

# --------------------------------------------------------------------------
# Generate configuration file
# --------------------------------------------------------------------------
mkdir -p /app/conf

bashio::log.info "Generating Diematic32MQTT.conf (connection_type=${CONNECTION_TYPE})"

cat > /app/conf/Diematic32MQTT.conf << CONFEOF
[Modbus]
connectionType: ${CONNECTION_TYPE}
serialPort: ${SERIAL_PORT}
baudrate: ${SERIAL_BAUDRATE}
ip: ${TCP_IP}
port: ${TCP_PORT}
regulatorAddress: ${REGULATOR_ADDRESS}
interfaceAddress: 0x32

[MQTT]
brokerHost: ${MQTT_HOST}
brokerPort: ${MQTT_PORT}
brokerLogin: ${MQTT_LOGIN}
brokerPassword: ${MQTT_PASSWORD}
topicPrefix: ${MQTT_TOPIC_PREFIX}
clientId: ${MQTT_CLIENT_ID}

[Boiler]
regulatorType: ${REGULATOR_TYPE}
timezone: ${TIMEZONE}
timeSync: ${TIME_SYNC}
period: ${PERIOD}
enable_circuit_A: ${ENABLE_CIRCUIT_A}
enable_circuit_B: ${ENABLE_CIRCUIT_B}

[Home Assistant]
MQTT_DiscoveryEnable: ${HA_DISCOVERY}
discovery_prefix: ${HA_DISCOVERY_PREFIX}
CONFEOF

# --------------------------------------------------------------------------
# Install logging config (keep user's version if already present)
# --------------------------------------------------------------------------
if [ ! -f /app/conf/logging.conf ]; then
    cp /app/conf_default/logging.conf /app/conf/logging.conf
fi

# --------------------------------------------------------------------------
# Launch
# --------------------------------------------------------------------------
bashio::log.info "Starting Diematic to MQTT bridge..."
cd /app
exec python3 Diematic32MQTT.py
