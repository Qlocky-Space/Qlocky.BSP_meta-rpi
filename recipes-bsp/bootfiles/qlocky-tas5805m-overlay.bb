SUMMARY = "Qlocky TAS5805M Raspberry Pi overlay"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "dtc-native"

SRC_URI = "file://qlocky-tas5805m-overlay.dts"

S = "${WORKDIR}"

inherit deploy

do_compile() {
    ${STAGING_BINDIR_NATIVE}/dtc -@ -H epapr -I dts -O dtb \
        -o ${B}/qlocky-tas5805m.dtbo ${WORKDIR}/qlocky-tas5805m-overlay.dts
}

do_deploy() {
    install -Dm0644 ${B}/qlocky-tas5805m.dtbo ${DEPLOYDIR}/qlocky-tas5805m.dtbo
}

addtask deploy after do_compile before do_build
