# Yocto Build Environment for Raspberry Pi 5 with RAUC
# =====================================================
# Based on Ubuntu 22.04 LTS (well-tested with Yocto)

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Yocto build dependencies
# Note: Using [trusted=yes] to work around Docker ARM64 GPG signature verification issues
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check && \
    sed -i 's|http://|[trusted=yes] http://|g' /etc/apt/sources.list && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && apt-get install -y --no-install-recommends \
    gawk \
    wget \
    git \
    diffstat \
    unzip \
    texinfo \
    gcc \
    build-essential \
    chrpath \
    socat \
    cpio \
    python3 \
    python3-pip \
    python3-pexpect \
    python3-git \
    python3-jinja2 \
    python3-subunit \
    openssl \
    ca-certificates \
    xz-utils \
    debianutils \
    iputils-ping \
    zstd \
    liblz4-tool \
    file \
    locales \
    libacl1 \
    lz4 \
    vim \
    tmux \
    screen \
    sudo \
    bmap-tools \
    && rm -rf /var/lib/apt/lists/*

# Set up locale (required by Yocto)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root user for building (Yocto refuses to build as root)
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=yocto

RUN groupadd -g ${GROUP_ID} ${USERNAME} 2>/dev/null || true && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash ${USERNAME} 2>/dev/null || \
    useradd -m -u ${USER_ID} -s /bin/bash ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up working directory
WORKDIR /yocto

# Switch to non-root user
USER ${USERNAME}

# Default command - start bash
CMD ["/bin/bash"]
