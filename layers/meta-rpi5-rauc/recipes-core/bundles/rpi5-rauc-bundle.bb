# RAUC Update Bundle Recipe
# =========================
# Creates a signed RAUC bundle for OTA updates

SUMMARY = "RAUC update bundle for Raspberry Pi 5"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit bundle

RAUC_BUNDLE_COMPATIBLE = "rpi5-rauc"
RAUC_BUNDLE_VERSION = "1.0-${DATETIME}"
RAUC_BUNDLE_DESCRIPTION = "RPi5 RAUC Update Bundle"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "rpi5-rauc-image"
RAUC_SLOT_rootfs[fstype] = "ext4"

RAUC_KEY_FILE = "${THISDIR}/../../../files/signing.key.pem"
RAUC_CERT_FILE = "${THISDIR}/../../../files/signing.cert.pem"
