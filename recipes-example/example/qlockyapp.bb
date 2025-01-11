SUMMARY = "Qlocky Sandbox UI"
SECTION = "examples"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# https://embeddeduse.com/2024/03/12/a-yocto-recipe-for-qt-applications-built-with-cmake/
inherit cmake
EXTRA_OECMAKE += " \
    -DQT_HOST_PATH:PATH=${RECIPE_SYSROOT_NATIVE}${prefix_native}/ \
    -DCMAKE_MODULE_PATH=${STAGING_DIR_TARGET}/${libdir}/cmake/QlockyApp \
"

SRC_URI = "git://github.com/Qlocky-Space/Qlocky.SandboxUi.git;protocol=https;branch=minimal"
SRCREV = "${AUTOREV}"
S = "${WORKDIR}/git"

DEPENDS += "qtbase qtdeclarative qttools-native"

