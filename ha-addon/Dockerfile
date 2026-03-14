ARG BUILD_FROM
FROM ${BUILD_FROM}

WORKDIR /app

# Install Python dependencies
COPY src/requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy Python source files
COPY src/*.py ./

# Keep a copy of the default logging config so run.sh can use it
COPY src/conf/logging.conf ./conf_default/logging.conf

# Copy and prepare the add-on entrypoint
COPY ha-addon/run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
