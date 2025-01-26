# Pulled from a mix of different images:
include recipes-core/images/core-image-minimal.bb 

SUMMARY = "The minimal image that can run Qt6 applications"
LICENSE = "MIT"

MY_TOOLS = " \
    qtbase \
    qtbase-dev \
    qtbase-plugins \
    qtbase-tools \
"

MY_PKGS = " \
    qtmultimedia \
    qtdeclarative \
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
    ${MY_TOOLS} \
    ${MY_PKGS} \
    ${MY_FEATURES} \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    qlockyapp \
"