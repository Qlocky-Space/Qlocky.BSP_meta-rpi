#!/bin/sh

. sources/meta-qlocky/tools/rpi-setup-release.sh

# add custom Qlocky layers
echo "# Qlocky Release layers" >> $BUILD_DIR/conf/bblayers.conf
hook_in_layer meta-qlocky

