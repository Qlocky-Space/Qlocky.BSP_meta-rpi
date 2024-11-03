#!/bin/sh
#
# RPI Yocto Project Build Environment Setup Script

. sources/meta-qlocky/tools/setup-utils.sh

CWD=`pwd`
PROGNAME="sources/poky/oe-init-build-env"
exit_message ()
{
   echo "To return to this build environment later please run:"
   echo "    source setup-environment <build_dir>"

}

usage()
{
    echo -e "\nUsage: source rpi-setup-release.sh
    Optional parameters: [-b build-dir] [-h]"
echo "
    * [-b build-dir]: Build directory, if unspecified script uses 'build' as output directory
    * [-h]: help
"
}


clean_up()
{

    unset CWD BUILD_DIR FSLDISTRO
    unset fsl_setup_help fsl_setup_error fsl_setup_flag
    unset usage clean_up
    unset ARM_DIR META_FSL_BSP_RELEASE
    exit_message clean_up
}

# get command line options
OLD_OPTIND=$OPTIND
unset FSLDISTRO

while getopts "k:r:t:b:e:gh" fsl_setup_flag
do
    case $fsl_setup_flag in
        b) BUILD_DIR="$OPTARG";
           echo -e "\nBuild directory is " $BUILD_DIR
           ;;
        h) fsl_setup_help='true';
           ;;
        \?) fsl_setup_error='true';
           ;;
    esac
done
shift $((OPTIND-1))
if [ $# -ne 0 ]; then
    fsl_setup_error=true
    echo -e "Invalid command line ending: '$@'"
fi
OPTIND=$OLD_OPTIND
if test $fsl_setup_help; then
    usage && clean_up && return 1
elif test $fsl_setup_error; then
    clean_up && return 1
fi


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

. $OEROOT/oe-init-build-env $CWD/$1 > /dev/null

# run basic setup
. ./$PROGNAME $BUILD_DIR > /dev/null

# if conf/local.conf not generated, no need to go further
if [ ! -e conf/local.conf ]; then
    clean_up && return 1
fi

# Clean up PATH, because if it includes tokens to current directories somehow,
# wrong binaries can be used instead of the expected ones during task execution
export PATH="`echo $PATH | sed 's/\(:.\|:\)*:/:/g;s/^.\?://;s/:.\?$//'`"

# Point to the current directory since the last command changed the directory to $BUILD_DIR
BUILD_DIR=.

if [ ! -e $BUILD_DIR/conf/local.conf ]; then
    echo -e "\n ERROR - No build directory is set yet. Run the 'setup-environment' script before running this script to create " $BUILD_DIR
    echo -e "\n"
    return 1
fi

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

if [ ! -e $BUILD_DIR/conf/bblayers.conf.org ]; then
    cp $BUILD_DIR/conf/bblayers.conf $BUILD_DIR/conf/bblayers.conf.org
else
    cp $BUILD_DIR/conf/bblayers.conf.org $BUILD_DIR/conf/bblayers.conf
fi

# Copy template
cp $CWD/sources/meta-qlocky/tools/bblayers.template $BUILD_DIR/conf/bblayers.conf

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

cat <<EOF
Your build environment has been configured with:
    MACHINE=$MACHINE
    DISTRO=$DISTRO
    SDKMACHINE=$SDKMACHINE

    BSPDIR=$BSPDIR
    BUILD_DIR=$BUILD_DIR
EOF

cd  $BUILD_DIR
clean_up
unset FSLDISTRO
