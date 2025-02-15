DISTRO_FEATURES:remove = "egl eglfs ptest"

PACKAGECONFIG:append = " kms gbm linuxfb icu tslib accessibility widgets"

IMAGE_INSTALL:append = " \
    qt6-wayland \
    qt6-wayland-plugins \
    qt6-env \
"

DISTRO_FEATURES:append = " wayland"

IMAGE_INSTALL:append = "\
    dev-pkgs \
    accessibility \
    widgets \
    xkbcommon \
"

# https://forum.qt.io/post/766385
# EXTRA_OECMAKE += "-DQT_FEATURE_egl=ON -DFEATURE_opengl=ON"
EXTRA_OECMAKE += "-DQT_QPA_PLATFORM=wayland"

do_configure:append() {
    export testVar="${S}"
}