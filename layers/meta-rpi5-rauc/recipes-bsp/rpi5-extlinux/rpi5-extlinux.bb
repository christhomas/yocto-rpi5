SUMMARY = "Extlinux configuration for RPi5 with RAUC A/B support"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://extlinux.conf"

inherit deploy

do_deploy() {
    install -d ${DEPLOYDIR}/extlinux
    install -m 0644 ${WORKDIR}/extlinux.conf ${DEPLOYDIR}/extlinux/extlinux.conf
}

addtask deploy after do_install before do_build

PACKAGE_ARCH = "${MACHINE_ARCH}"
