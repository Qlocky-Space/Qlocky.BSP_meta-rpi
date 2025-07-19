inherit core-image

SUMMARY = "The minimal image that can run Qt6 applications"
LICENSE = "MIT"

MY_TOOLS = " \
    gdb \
    gdbserver \
"

QT_TOOLS = " \
    packagegroup-qt6-modules \
    qtbase-dev \
    qttools \
    qttools-tools \
    qtbase-plugins \
    boost \
    boost-staticdev \
"

BSP_FEATURES = " \
    linux-firmware-bcm43455 \
    bluez5 \
    i2c-tools \
    bridge-utils \
    iptables \
    wpa-supplicant \
    packagegroup-core-boot \
    kernel-modules \
    openssh \
    rocksdb \
    glibc-dev \
"

CORE_IMAGE_EXTRA_INSTALL:append = "\
    weston \
    weston-init \
    wayland \
    wayland-protocols \
"

MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "kernel-module-brcmfmac"

# https://docs.yoctoproject.org/3.2/ref-manual/ref-features.html#image-features
IMAGE_FEATURES:append = " hwcodecs"

DISTRO_FEATURES:append = " alsa wifi gles2 qt6"

# QT configuration
PACKAGECONFIG:append:pn-qtbase = " declarative qttools qttools-native qttranslations accessibility fontconfigq q libs gl zlib gui eglfs gles2 png zlib libinput jpge"
IMAGE_INSTALL:remove = " qt3d qtquick3d"
TOOLCHAIN_TARGET_TASK:remove = " qt3d qtquick3d"

RDEPENDS += " weston-init"


IMAGE_INSTALL:append = " \
    ${MY_TOOLS} \
    ${QT_TOOLS} \
    ${BSP_FEATURES} \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    qlockyapp \
"
# ROOTFS_POSTPROCESS_COMMAND += "enable_ssh_service;"

# enable_ssh_service() {
#     ln -s /lib/systemd/system/sshd.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/sshd.service
# }