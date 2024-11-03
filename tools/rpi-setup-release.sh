#!/bin/sh
#
# RPI Yocto Project Build Environment Setup Script

. sources/meta-qlocky/tools/setup-utils.sh

CWD=`pwd`
PROGNAME="setup-environment"

exit_message () {
    echo -e ""
    echo "To return to this build environment later please run:"
    echo "    source setup-environment <build_dir>"
}

usage() {
    echo -e "\nUsage: source rpi-setup-release.sh
    Optional parameters: [-b build-dir] [-h]"
    echo "
        * [-b build-dir]: Build directory, if unspecified script uses 'build' as output directory
        * [-h]: help
    "
}

clean_up() {
    exit_message

    unset CWD BUILD_DIR FSLDISTRO
    unset fsl_setup_help fsl_setup_error fsl_setup_flag
    unset usage exit_message
    unset modify_local_conf modify_layer_conf
    unset ARM_DIR META_FSL_BSP_RELEASE
}

modify_local_conf() {  
    # On the first script run, backup the local.conf file
    # Consecutive runs, it restores the backup and changes are appended on this one.
    if [ ! -e $BUILD_DIR/conf/local.conf.org ]; then
        cp $BUILD_DIR/conf/local.conf $BUILD_DIR/conf/local.conf.org
    else
        cp $BUILD_DIR/conf/local.conf.org $BUILD_DIR/conf/local.conf
    fi

    # Change settings according environment
    sed -e "s,MACHINE ??=.*,MACHINE ??= '$MACHINE',g" \
        -e "s,SDKMACHINE ??=.*,SDKMACHINE ??= '$SDKMACHINE',g" \
        -e "s,DISTRO ?=.*,DISTRO ?= '$DISTRO',g" \
        -i $BUILD_DIR/conf/local.conf

    echo >> $BUILD_DIR/conf/local.conf 
    echo "# Enable UART to ensure it can be used to print logs" >> $BUILD_DIR/conf/local.conf 
    echo "ENABLE_UART = \"1\"" >> $BUILD_DIR/conf/local.conf 

    echo >> $BUILD_DIR/conf/local.conf
    echo "# Switch to rpm packaging in the image" >> $BUILD_DIR/conf/local.conf
    echo "PACKAGE_CLASSES = \"package_rpm\"" >> $BUILD_DIR/conf/local.conf
}

modify_layer_conf() {  
    if [ ! -e $BUILD_DIR/conf/bblayers.conf.org ]; then
        cp $BUILD_DIR/conf/bblayers.conf $BUILD_DIR/conf/bblayers.conf.org
    else
        cp $BUILD_DIR/conf/bblayers.conf.org $BUILD_DIR/conf/bblayers.conf
    fi

    # Copy template
    cp $BUILD_DIR/../sources/meta-qlocky/tools/bblayers.template $BUILD_DIR/conf/bblayers.conf

    echo "" >> $BUILD_DIR/conf/bblayers.conf
    echo "# RPI Yocto Project Release layers" >> $BUILD_DIR/conf/bblayers.conf
    hook_in_layer meta-raspberrypi

    echo "" >> $BUILD_DIR/conf/bblayers.conf
    hook_in_layer meta-arm/meta-arm
    hook_in_layer meta-arm/meta-arm-toolchain
    hook_in_layer meta-clang
    hook_in_layer meta-openembedded/meta-oe
    hook_in_layer meta-openembedded/meta-python
    hook_in_layer meta-openembedded/meta-networking
    hook_in_layer meta-openembedded/meta-filesystems
    hook_in_layer meta-qt6
}

# get command line options
OLD_OPTIND=$OPTIND
unset FSLDISTRO

while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--build)
      BUILD_DIR="$2";
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      usage && clean_up && return 1
      ;;
    *)
      shift # past argument
      ;;
  esac
done

if [ -z "$DISTRO" ]; then
    if [ -z "$FSLDISTRO" ]; then
        FSLDISTRO='pocky'
    fi
else
    FSLDISTRO="$DISTRO"
fi

if [ -z "$BUILD_DIR" ]; then
    BUILD_DIR='build'
fi

if [ -z "$MACHINE" ]; then
    echo setting to default machine
    MACHINE='raspberrypi-64'
fi

OEROOT=$PWD/sources/poky
if [ -e $PWD/sources/oe-core ]; then
    OEROOT=$PWD/sources/oe-core
fi

# run basic setup
. ./$PROGNAME $BUILD_DIR > /dev/null

# if conf/local.conf not generated, no need to go further
if [ ! -e conf/local.conf ]; then
    clean_up && return 1
fi

# Point to the current directory since the last command changed the directory to $BUILD_DIR
BUILD_DIR=$PWD

if [ ! -e conf/local.conf ]; then
    echo -e "\n ERROR - No build directory is set yet. Run the 'setup-environment' script before running this script to create " $BUILD_DIR
    echo -e "\n"
    return 1
fi


modify_local_conf
modify_layer_conf

cat <<EOF 

Your build environment has been configured with:
    MACHINE = $MACHINE
    DISTRO = $DISTRO
    SDKMACHINE = $SDKMACHINE
    BUILD_DIR = $BUILD_DIR

EOF

exit_message
clean_up

cd $BUILD_DIR/..

