FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Keep any config fragments you actually need
SRC_URI += " \
    file://rauc-env-nowhere.cfg \
    file://rauc-bootstd.cfg \
    file://rauc-video.cfg \
"

UBOOT_CONFIG_FRAGMENTS:append = " \
    rauc-env-nowhere.cfg \
    rauc-bootstd.cfg \
    rauc-video.cfg \
"
