FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://config.txt \
"

do_deploy:append() {
    # Force our project-specific config.txt to be deployed verbatim
    install -m 0644 -T "${WORKDIR}/config.txt" "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt"
}
