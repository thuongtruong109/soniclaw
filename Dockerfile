FROM ubuntu:resolute-20260108

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y git curl net-tools nano openssh-server jq iproute2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd && \
    echo 'root:root@123' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22 18789

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
