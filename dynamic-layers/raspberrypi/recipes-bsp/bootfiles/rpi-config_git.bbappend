
do_deploy:append() {
    echo "# enable both hdmi outputs" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "max_framebuffers=2" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt

    echo "# Use fake kms for backward compatibility" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "dtoverlay=vc4-fkms-v3d" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt

    echo "# HDMI configuration" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_force_hotplug=1" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_force_mode=1" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_mode=87" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_group=2" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_timings=1080 1 8 2 4 1920 1 48 6 25 0 0 0 60 0 134490000 3" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
}
