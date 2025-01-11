DISTRO_FEATURES:remove = " x11 wayland ptest"
PACKAGECONFIG:append = " accessibility eglfs fontconfig gles2 linuxfb tslib gbm"

# https://forum.qt.io/post/766385
# EXTRA_OECMAKE += "-DQT_FEATURE_egl=ON -DFEATURE_opengl=ON"