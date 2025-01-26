#!/bin/sh

# the other option is linuxfb if just using qt widgets
export QT_QPA_PLATFORM=eglfs

# for the pitft28r 320x240 touchscreen
export QT_QPA_EGLFS_WIDTH=1080
export QT_QPA_EGLFS_HEIGHT=1920
export QT_QPA_EGLFS_PHYSICAL_WIDTH=68
export QT_QPA_EGLFS_PHYSICAL_HEIGHT=122
# set a rotate value appropriate with the one used in the overlay 
export QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS=/dev/input/touchscreen0:rotate=90

if [ -z "${XDG_RUNTIME_DIR}" ]; then
    export XDG_RUNTIME_DIR=/tmp/user/${UID}

    if [ ! -d ${XDG_RUNTIME_DIR} ]; then
        mkdir -p ${XDG_RUNTIME_DIR}
    fi
fi