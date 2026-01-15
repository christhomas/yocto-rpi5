SUMMARY = "RAUC boot assets for RPi5 (single extlinux.conf)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit deploy

## No mkimage needed when not generating boot.scr

## Provide u-boot-default-script so dependencies are satisfied (we still rely on extlinux bootflow)
PROVIDES += "u-boot-default-script"

SRC_URI = " \
    file://extlinux.conf \
"

S = "${WORKDIR}"

do_deploy() {
    install -d ${DEPLOYDIR}/extlinux
    install -m 0644 ${WORKDIR}/extlinux.conf ${DEPLOYDIR}/extlinux/extlinux.conf
}

addtask deploy after do_compile before do_build
