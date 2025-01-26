# network configuration: https://hub.mender.io/t/how-to-configure-networking-using-systemd-in-yocto-project/1097
PACKAGECONFIG:append = " networkd resolved"

RDEPENDS:${PN}:append = " wpa-supplicant "