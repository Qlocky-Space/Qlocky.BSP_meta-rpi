# https://lists.yoctoproject.org/g/yocto/topic/meta_raspberrypi/99727959
VC4DTBO = "vc4-fkms-v3d"


do_deploy:append() {
    echo "# HDMI configuration" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_force_hotplug=1" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_force_mode=1" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_mode=87" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_group=2" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_timings=1080 1 8 2 4 1920 1 48 6 25 0 0 0 30 0 65607180 3" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "disable_overscan=1" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt

    # echo "hdmi_edid_file=1" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    # echo "hdmi_edid_filename=edid.dat" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt    
}
