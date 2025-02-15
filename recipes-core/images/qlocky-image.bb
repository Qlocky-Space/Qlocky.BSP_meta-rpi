# Pulled from a mix of different images:
inherit core-image


# TODO Rotate screen
#this command rotate console
#echo 3 > /sys/class/graphics/fbcon/rotate

SUMMARY = "The minimal image that can run Qt6 applications"
LICENSE = "MIT"

DEV_TOOLS = " \
    gdb \
    gdbserver \
"

MY_TOOLS = " \
    qtbase \
    qtbase-dev \
    qtbase-plugins \
    qtbase-tools \
    qtwayland \
    qt6-env \
"

MY_PKGS = " \
    qtmultimedia \
    qtdeclarative \
"

FONTS = "\
    fontconfig \
    fontconfig-utils \
    ttf-droid-sans \
    ttf-dejavu-sans \
    ttf-dejavu-sans-mono \
    ttf-dejavu-sans-condensed \
    ttf-dejavu-serif \
    ttf-dejavu-serif-condensed \
    ttf-dejavu-common \
"


MY_FEATURES = " \
    linux-firmware-bcm43455 \
    bluez5 \
    i2c-tools \
    bridge-utils \
    iptables \
    wpa-supplicant \
    packagegroup-core-boot \
    kernel-modules \
    openssh \
    weston \
    weston-init \
    wayland \
    wayland-protocols \
"

DISTRO_FEATURES:append = " splash package-management efi bluez5 bluetooth wifi weston systemd wayland"

MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "kernel-module-brcmfmac"

SYSTEMD_AUTO_ENABLE:append = " weston"
CORE_IMAGE_EXTRA_INSTALL += "wayland weston"

CORE_IMAGE_BASE_INSTALL += "${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'weston-xwayland matchbox-terminal', '', d)}"

QB_MEM = "-m 512"


IMAGE_INSTALL:append = " \
    ${FONTS} \
    ${MY_TOOLS} \
    ${DEV_TOOLS} \
    ${MY_PKGS} \
    ${MY_FEATURES} \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    qlockyapp \
"