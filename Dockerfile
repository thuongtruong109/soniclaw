FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
# Pin OpenClaw version — do not use "latest" at runtime
ENV OPENCLAW_VERSION=2026.11.2

RUN apt-get update && \
    apt-get install -y git curl ca-certificates net-tools nano openssh-server jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Lock down SSH: disable password auth, use key-only, restrict to non-root
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Install OpenClaw at a fixed version — not fetched at container start
RUN curl -fsSL https://openclaw.ai/install.sh | \
    OPENCLAW_VERSION=${OPENCLAW_VERSION} bash -s -- --no-onboard

ENV PATH="/root/.local/bin:${PATH}"

EXPOSE 18789

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
