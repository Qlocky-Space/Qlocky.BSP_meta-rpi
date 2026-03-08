FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SPLASH_IMAGES = "file://SplashScreen.png;outsuffix=default"

EXTRA_OECONF += "--disable-startup-msg --enable-img-fullscreen"