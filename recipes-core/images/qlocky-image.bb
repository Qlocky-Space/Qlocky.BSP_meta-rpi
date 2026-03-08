inherit core-image

SUMMARY = "The minimal image that can run Qt6 applications"
LICENSE = "MIT"

# pulseaudio 
# pulseaudio-server 
# pulseaudio-misc 
MY_TOOLS = " \
    gdb \
    gdbserver \
    gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
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
    alsa-utils \
    sdbus-c++ \
    sdbus-c++-tools \
    glibc-dev \
"

CORE_IMAGE_EXTRA_INSTALL:append = "\
    weston \
    weston-init \
    wayland \
    wayland-protocols \
"

MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "kernel-module-brcmfmac"
MACHINE_FEATURES += " alsa"


# https://docs.yoctoproject.org/3.2/ref-manual/ref-features.html#image-features
IMAGE_FEATURES:append = " hwcodecs splash empty-root-password serial-autologin-root weston"

# pulseaudio
DISTRO_FEATURES:append = " alsa wifi ipv4 gles2 qt6 api-documentation "

# QT configuration
PACKAGECONFIG:append:pn-qtbase = " declarative qttools qttools-native qttranslations accessibility fontconfigq q libs gl zlib gui eglfs gles2 png zlib libinput jpge"
# PACKAGECONFIG:append:pn-pulseaudio = " tcpwrap zeroconf"
IMAGE_INSTALL:remove = " qt3d qtquick3d"
TOOLCHAIN_TARGET_TASK:remove = " qt3d qtquick3d"

RDEPENDS += " weston-init"

IMAGE_BOOT_FILES:append = " qlocky-tas5805m.dtbo;overlays/qlocky-tas5805m.dtbo"

do_image_wic[depends] += " qlocky-tas5805m-overlay:do_deploy"

IMAGE_INSTALL:append = " \
    ${MY_TOOLS} \
    ${QT_TOOLS} \
    ${BSP_FEATURES} \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    qlocky-audio-init \
    qlocky-tas5805m-firmware \
    qlockyapp \
"


#TODO
# At the moment, /etc/wpa_supplicant/wpa_supplicant.conf needs to modified manually
# --> ExecStart=/usr/sbin/wpa_supplicant -u -i wlan0 -c /etc/wpa_supplicant.conf