FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
# Pin the OpenClaw version; never install "latest" at runtime.
ENV OPENCLAW_VERSION=2026.11.2
ENV PATH="/root/.local/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        nano && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install OpenClaw at a fixed version at build time.
RUN curl -fsSL https://openclaw.ai/install.sh | \
    OPENCLAW_VERSION=${OPENCLAW_VERSION} bash -s -- --no-onboard

EXPOSE 18789

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
