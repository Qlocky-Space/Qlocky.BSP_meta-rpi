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
    bluez5 \
    i2c-tools \
    bridge-utils \
    hostapd \
    iptables \
    wpa-supplicant \
"

DISTRO_FEATURES += " efi bluez5 bluetooth wifi"
IMAGE_INSTALL = " \
    ${MY_TOOLS} \
    ${MY_PKGS} \
    ${MY_FEATURES} \
    basicquick \
"