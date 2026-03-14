# syntax=docker/dockerfile:1
#
# Unified Dockerfile for both standalone Docker and Home Assistant OS add-on.
#
# Standalone:  docker build .
#              docker run --device /dev/ttyUSB1 -v $(pwd)/src/conf:/app/conf <image>
#              (override CMD with: python3 Diematic32MQTT.py)
#
# HA-OS add-on: BUILD_FROM is injected automatically by the HA builder.

ARG BUILD_FROM=python:3.8-alpine
FROM ${BUILD_FROM}

WORKDIR /app

COPY src/requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

COPY src/*.py ./

# Default logging config (seeded into /app/conf/ on first start by run.sh)
COPY src/conf/logging.conf ./conf_default/logging.conf

# HA-OS add-on entrypoint (requires bashio – present in HA base images)
COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
