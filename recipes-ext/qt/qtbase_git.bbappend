DISTRO_FEATURES:remove = " x11 ptest"

PACKAGECONFIG_GL = " ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'gles2', '', d)} "
PACKAGECONFIG:append = " eglfs kms gbm linuxfb fontconfig icu gles2 tslib accessibility widgets"
QT_CONFIG_FLAGS += " -no-sse2 -no-opengles3"

IMAGE_INSTALL:append = "\
    ttf-dejavu-sans \
    ttf-dejavu-sans-mono \
    ttf-dejavu-sans-condensed \
    ttf-dejavu-serif \
    ttf-dejavu-serif-condensed \
    ttf-dejavu-common \
"

IMAGE_INSTALL:append = "\
    dev-pkgs \
"

# https://forum.qt.io/post/766385
EXTRA_OECMAKE += "-DQT_FEATURE_egl=ON -DFEATURE_opengl=ON"