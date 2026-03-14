# syntax=docker/dockerfile:1
#
# Works for both HA-OS add-on and standalone Docker.
# No HA base image required – uses standard Python Alpine.

FROM python:3.11-alpine

WORKDIR /app

COPY src/requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

COPY src/*.py ./

# Default logging config (seeded into /app/conf/ on first start by run.sh)
COPY src/conf/logging.conf ./conf_default/logging.conf

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
