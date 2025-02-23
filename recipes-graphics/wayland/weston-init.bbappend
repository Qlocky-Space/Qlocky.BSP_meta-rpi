# because file names are identical to original recipes, yocto take care of and overwrite with custom files
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DISTRO_FEATURES:remove = "x11"
PACKAGECONFIG:remove = "x11"