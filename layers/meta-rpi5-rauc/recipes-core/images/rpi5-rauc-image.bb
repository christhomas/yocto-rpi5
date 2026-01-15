# Raspberry Pi 5 Image with RAUC A/B Update Support
# ==================================================

SUMMARY = "Raspberry Pi 5 image with RAUC A/B update support"
LICENSE = "MIT"

inherit core-image

# Base image features
IMAGE_FEATURES += " \
    ssh-server-dropbear \
    package-management \
"

# Core packages
IMAGE_INSTALL += " \
    base-files \
    base-passwd \
    busybox \
    kernel-modules \
"

# Networking
IMAGE_INSTALL += " \
    dhcpcd \
    openssh-sftp-server \
"

# System utilities
IMAGE_INSTALL += " \
    util-linux \
    e2fsprogs \
    dosfstools \
    parted \
"

# RAUC update framework
IMAGE_INSTALL += " \
    rauc \
    rauc-service \
"

IMAGE_INSTALL += " \
    rpi5-ssh-user \
"

# U-Boot tools for boot slot management
IMAGE_INSTALL += " \
    libubootenv-bin \
"

# Persistent data directory
IMAGE_INSTALL += " \
    rpi5-rauc-data-mount \
"

IMAGE_BOOT_FILES:append = " \
    u-boot.bin;kernel_2712.img \
"

# Root filesystem size (8GB per slot)
IMAGE_ROOTFS_SIZE = "8388608"

# Extra space for packages
IMAGE_ROOTFS_EXTRA_SPACE = "0"

# Use our A/B partition WKS file
WKS_FILE = "rpi5-rauc-ab.wks"
