SUMMARY = "Add Qt6 bin dir to PATH"

LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://qt6-env.sh"

PR = "r1"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/profile.d
    install -m0755 qt6-env.sh ${D}${sysconfdir}/profile.d
}

FILES_${PN} = "${sysconfdir}"