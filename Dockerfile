# official Python runtime
FROM python:3.12-slim

# Metadata as described in the original Dockerfile
LABEL Description="CyberPower PowerPanel"
LABEL Maintainer="Daniel Winks"

# Set environment variables
ENV DEB="PPL_64bit_v1.4.1.deb"

# Create a non-root user
RUN useradd -ms /bin/bash app -u 1555

# Copy only the necessary files
COPY --chown=app:app *.py requirements.txt "${DEB}" init.sh pwrstat.yaml /home/app/
COPY pwrstatd.conf /etc/pwrstatd.conf

# Install any needed packages
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  procps curl /home/app/"${DEB}" && \
  pip install --no-cache-dir --trusted-host pypi.python.org -r /home/app/requirements.txt && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /home/app/"${DEB}"

# Set permissions
RUN chmod +x /home/app/init.sh /home/app/*.py

# Change to non-root user
USER app

# Set working directory
WORKDIR /home/app

# Run init.sh when the container launches
CMD ["/home/app/init.sh"]
