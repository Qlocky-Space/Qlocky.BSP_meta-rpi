SUMMARY = "Qlocky TAS5805M DSP firmware"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware
    printf '\x00\x00' > ${D}${nonarch_base_libdir}/firmware/tas5805m_dsp_default.bin
}

FILES:${PN} = "${nonarch_base_libdir}/firmware/tas5805m_dsp_default.bin"
