SUMMARY = "Simple Qt6 Quick application"
SECTION = "examples"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# I want to make sure these get installed too.
DEPENDS += "qtbase"

SRCREV = "${AUTOREV}"
SRC_URI = "git://github.com/shigmas/BasicQuick.git;protocol=https;branch=master"

S = "${WORKDIR}/git"

require recipes-qt/qt6/qt6.inc

do_install() {
      install -d ${D}${bindir}
      install -m 0755 BasicQuick ${D}${bindir}
}