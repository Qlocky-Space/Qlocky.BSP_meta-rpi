# because file names are identical to original recipes, yocto take care of and overwrite with custom files
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DISTRO_FEATURES:remove = "x11"
PACKAGECONFIG:remove = "x11"

# Override the weston.service to run as root for DRM/KMS access on Raspberry Pi.
# This replaces the upstream weston-autologin/PAM approach with a simpler root-based kiosk setup.
# SRC_URI:append = " file://weston.service"