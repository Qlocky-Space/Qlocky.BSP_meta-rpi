#!/bin/sh

# the other option is linuxfb if just using qt widgets
export QT_QPA_PLATFORM=wayland

if [ -z "${XDG_RUNTIME_DIR}" ]; then
    export XDG_RUNTIME_DIR=/tmp/user/${UID}

    if [ ! -d ${XDG_RUNTIME_DIR} ]; then
        mkdir -p ${XDG_RUNTIME_DIR}
    fi
fi