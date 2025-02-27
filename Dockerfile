# Use an official Alpine base image
FROM alpine:latest

# Install required utilities
RUN apk add --no-cache curl tar bash

# Set working directory
WORKDIR /otel

# Download and extract the Elastic Agent for OpenTelemetry
RUN arch=$(if [[ $(uname -m) == "arm64" ]]; then echo "arm64"; else echo "x86_64"; fi) && \
    curl -L -o elastic-agent.tar.gz "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.17.0-linux-$arch.tar.gz" && \
    mkdir -p elastic-distro && \
    tar -xvf elastic-agent.tar.gz -C elastic-distro --strip-components=1 && \
    rm elastic-agent.tar.gz

# Set up OpenTelemetry configuration
COPY otel.yml /otel/elastic-distro/otel.yml
RUN mkdir -p /otel/data/otelcol && \
    sed -i 's#\${env:STORAGE_DIR}#/otel/data/otelcol#g' /otel/elastic-distro/otel.yml && \
    sed -i 's#\${env:ELASTIC_ENDPOINT}#https://b3fa85ebdcb844ebb2936849f1304ee8.us-east-1.aws.found.io:443#g' /otel/elastic-distro/otel.yml && \
    sed -i 's#\${env:ELASTIC_API_KEY}#ZG1kcVI1VUJObEhacHNmNG1YR006cERFOFhCRnpUSU9rZTdfQko1MDF6QQ==#g' /otel/elastic-distro/otel.yml

# Set entrypoint to start the Elastic Agent OpenTelemetry Collector
CMD ["/otel/elastic-distro/elastic-agent", "run", "-c", "/otel/elastic-distro/otel.yml"]