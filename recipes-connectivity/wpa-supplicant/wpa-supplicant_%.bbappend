FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://10-qlocky-service.conf"

FILES:${PN} += "${systemd_system_unitdir}/wpa_supplicant.service.d/10-qlocky-service.conf"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}/wpa_supplicant.service.d
    install -m 0644 ${WORKDIR}/10-qlocky-service.conf \
        ${D}${systemd_system_unitdir}/wpa_supplicant.service.d/10-qlocky-service.conf
}