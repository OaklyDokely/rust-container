FROM debian:bullseye-slim

LABEL author="Pterodactyl Software" maintainer="support@pterodactyl.io"

ENV DOCKER_BUILDKIT=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    dpkg --add-architecture i386 \
    && apt update \
    && apt upgrade -y \
    && apt install -y \
        lib32gcc-s1 \
        lib32stdc++6 \
        unzip \
        curl \
        iproute2 \
        tzdata \
        libgdiplus \
        libsdl2-2.0-0:i386 \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt install -y nodejs \
    && npm install --prefix / ws \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -d /home/container -m container

# Copy scripts
COPY ./entrypoint.sh /entrypoint.sh
COPY ./install.sh /install.sh
COPY ./wrapper.js /wrapper.js

# Set permissions
RUN chmod +x /entrypoint.sh /install.sh /wrapper.js

# Switch to container user
USER container
WORKDIR /home/container

# Set environment variables
ENV USER=container HOME=/home/container

# Start the server
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]

