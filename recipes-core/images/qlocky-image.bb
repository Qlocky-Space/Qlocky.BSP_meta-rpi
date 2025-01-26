# Pulled from a mix of different images:
include recipes-core/images/core-image-minimal.bb 


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
"

MY_PKGS = " \
    qtmultimedia \
    qtdeclarative
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
"

DISTRO_FEATURES:append = " efi bluez5 bluetooth wifi"

MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "kernel-module-brcmfmac"


IMAGE_INSTALL = " \
    ${FONTS} \
    ${MY_TOOLS} \
    ${DEV_TOOLS} \
    ${MY_PKGS} \
    ${MY_FEATURES} \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    qlockyapp \
"