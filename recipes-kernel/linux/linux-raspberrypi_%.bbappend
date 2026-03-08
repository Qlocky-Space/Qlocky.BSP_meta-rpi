FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://qlocky-audio.cfg \
"

# Autoload I2C modules at boot so /dev/i2c-* is available without manual modprobe
KERNEL_MODULE_AUTOLOAD += "i2c-dev i2c-bcm2835"
