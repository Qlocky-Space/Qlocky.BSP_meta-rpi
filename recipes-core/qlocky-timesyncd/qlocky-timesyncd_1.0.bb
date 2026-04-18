SUMMARY = "Qlocky NTP configuration for systemd-timesyncd"
DESCRIPTION = "Installs a systemd-timesyncd drop-in with Qlocky NTP servers"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit allarch

SRC_URI = "file://10-qlocky-ntp.conf"

RDEPENDS:${PN} = "systemd"

FILES:${PN} += "${sysconfdir}/systemd/timesyncd.conf.d/10-qlocky-ntp.conf"

do_install() {
    install -d ${D}${sysconfdir}/systemd/timesyncd.conf.d
    install -m 0644 ${WORKDIR}/10-qlocky-ntp.conf ${D}${sysconfdir}/systemd/timesyncd.conf.d/10-qlocky-ntp.conf
}
