SUMMARY = "Qlocky compositor-side display power DBus service"
DESCRIPTION = "Weston module exposing ch.qlocky.DisplayPower1 on the system bus"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://qlocky-display-power.c \
    file://ch.qlocky.DisplayPower.conf \
    file://ch.qlocky.DisplayPower.service \
"

S = "${WORKDIR}"

DEPENDS = "weston dbus"

inherit pkgconfig

EXTRA_OECFLAGS += "${@bb.utils.contains('DISTRO_FEATURES', 'lto', '', '-fno-lto', d)}"

do_compile() {
    ${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -fPIC -shared \
        ${WORKDIR}/qlocky-display-power.c \
        -o ${B}/qlocky-display-power.so \
    $(pkg-config --cflags --libs libweston-13 wayland-server dbus-1)
}

do_install() {
    # Weston frontend modules (loaded via --modules=...) live under ${libdir}/weston.
    install -d ${D}${libdir}/weston
    install -m 0755 ${B}/qlocky-display-power.so ${D}${libdir}/weston/qlocky-display-power.so

    # Keep a copy in libweston module dir for compatibility with older search paths.
    install -d ${D}${libdir}/libweston-13
    install -m 0755 ${B}/qlocky-display-power.so ${D}${libdir}/libweston-13/qlocky-display-power.so

    install -d ${D}${sysconfdir}/dbus-1/system.d
    install -m 0644 ${WORKDIR}/ch.qlocky.DisplayPower.conf ${D}${sysconfdir}/dbus-1/system.d/ch.qlocky.DisplayPower.conf

    install -d ${D}${datadir}/dbus-1/system-services
    install -m 0644 ${WORKDIR}/ch.qlocky.DisplayPower.service ${D}${datadir}/dbus-1/system-services/ch.qlocky.DisplayPower.service
}

FILES:${PN} += " \
    ${libdir}/weston/qlocky-display-power.so \
    ${libdir}/libweston-13/qlocky-display-power.so \
    ${sysconfdir}/dbus-1/system.d/ch.qlocky.DisplayPower.conf \
    ${datadir}/dbus-1/system-services/ch.qlocky.DisplayPower.service \
"
