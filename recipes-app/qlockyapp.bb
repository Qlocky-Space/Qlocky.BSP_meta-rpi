SUMMARY = "Qlocky UI"
SECTION = "qlockyapp"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# https://embeddeduse.com/2024/03/12/a-yocto-recipe-for-qt-applications-built-with-cmake/
inherit qt6-cmake
EXTRA_OECMAKE += " \
    -DCMAKE_TARGET_SDK=Qlocky \
    -DCMAKE_FIND_ROOT_PATH=${STAGING_DIR_TARGET} \
    -DCMAKE_TOOLCHAIN_FILE=${RECIPE_SYSROOT_NATIVE}/usr/share/cmake/OEToolchainConfig.cmake \
    -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
"

# fixes access to internet while configuration, because qlockyapp has thirdpart dependencies
# https://lists.yoctoproject.org/g/yocto/topic/network_isolation_and_cmake/97782979
do_configure[network] = "1"

SRC_URI = "git://github.com/Qlocky-Space/Qlocky.Ui.git;protocol=https;branch=develop"
SRCREV = "${AUTOREV}"
PV = "1.0.0"
S = "${WORKDIR}/git"

DEPENDS += "qtbase qtdeclarative qtdeclarative-native"
