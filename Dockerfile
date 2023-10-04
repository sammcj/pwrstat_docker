# Use an official Python runtime as a parent image
FROM python:3.12-slim as builder

# Metadata as described in the original Dockerfile
LABEL Description="CyberPower PowerPanel"
LABEL Maintainer="Daniel Winks"

# Set environment variables
ENV DEB="PPL_64bit_v1.4.1.deb"

# Copy only the necessary files
COPY *.py requirements.txt "${DEB}" init.sh pwrstat.yaml /build/

# Install any needed packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    procps \
    curl && \
    pip install --no-cache-dir --trusted-host pypi.python.org -r /build/requirements.txt && \
    apt-get install -y /build/"${DEB}" && \
    apt-get -y --purge autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /build/"${DEB}"

# Create a non-root user
RUN useradd -ms /bin/bash app

# Change to non-root user
USER app

# Copy necessary files to appropriate locations
COPY --from=builder /build/*.py /build/init.sh /build/pwrstat.yaml /home/app/
COPY --from=builder /usr/local/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/

# Set permissions
RUN chmod +x /home/app/init.sh /home/app/*.py

# Set working directory
WORKDIR /home/app

# Run init.sh when the container launches
CMD ["/home/app/init.sh"]
