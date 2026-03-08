SUMMARY = "Qlocky ALSA I2S module autoload"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://qlocky-audio-modules.conf"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/modules-load.d
    install -m 0644 ${WORKDIR}/qlocky-audio-modules.conf ${D}${sysconfdir}/modules-load.d/qlocky-audio.conf
}

FILES:${PN} += "${sysconfdir}/modules-load.d/qlocky-audio.conf"
