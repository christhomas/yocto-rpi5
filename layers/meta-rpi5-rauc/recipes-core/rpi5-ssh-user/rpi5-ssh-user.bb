SUMMARY = "Create a managed SSH user and install authorized_keys"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RPI5_SSH_USERNAME ?= "dev"
RPI5_SSH_UID ?= "1000"
RPI5_SSH_GID ?= "1000"
RPI5_SSH_AUTHORIZED_KEYS_FILE ?= "authorized_keys"
RPI5_SSH_PUBLIC_KEY ?= ""

RDEPENDS:${PN} += "dropbear"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://${RPI5_SSH_AUTHORIZED_KEYS_FILE}"

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "--gid ${RPI5_SSH_GID} ${RPI5_SSH_USERNAME}"
USERADD_PARAM:${PN} = "--create-home --home-dir /home/${RPI5_SSH_USERNAME} --shell /bin/sh --uid ${RPI5_SSH_UID} --gid ${RPI5_SSH_USERNAME} ${RPI5_SSH_USERNAME}"

do_install() {
    install -d ${D}/home/${RPI5_SSH_USERNAME}/.ssh

    if [ -n "${RPI5_SSH_PUBLIC_KEY}" ]; then
        printf '%s\n' "${RPI5_SSH_PUBLIC_KEY}" > ${D}/home/${RPI5_SSH_USERNAME}/.ssh/authorized_keys
        chmod 0600 ${D}/home/${RPI5_SSH_USERNAME}/.ssh/authorized_keys
    else
        install -m 0600 ${WORKDIR}/${RPI5_SSH_AUTHORIZED_KEYS_FILE} ${D}/home/${RPI5_SSH_USERNAME}/.ssh/authorized_keys
    fi

    chown -R ${RPI5_SSH_UID}:${RPI5_SSH_USERNAME} ${D}/home/${RPI5_SSH_USERNAME}
    chmod 0700 ${D}/home/${RPI5_SSH_USERNAME}/.ssh
}

FILES:${PN} += " \
    /home/${RPI5_SSH_USERNAME}/.ssh/authorized_keys \
"
