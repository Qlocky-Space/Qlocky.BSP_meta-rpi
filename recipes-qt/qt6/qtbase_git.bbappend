DISTRO_FEATURES:remove = " x11 ptest"
DISTRO_FEATURES:append = " opengl egl gles2"

PACKAGECONFIG:append = " eglfs kms gbm linuxfb icu gles2 tslib accessibility widgets"

IMAGE_INSTALL:append = "\
    dev-pkgs \
"

# https://forum.qt.io/post/766385
EXTRA_OECMAKE += "-DQT_FEATURE_egl=ON -DFEATURE_opengl=ON"