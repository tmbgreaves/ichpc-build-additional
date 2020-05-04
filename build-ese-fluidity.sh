#!/bin/bash

# Set up initial environment

#### CHANGE THE NEXT LINE
PREFIX=/SET/YOUR/BUILD/DIRECTORY/HERE

FLUIDITY_GIT_URL=https://github.com/fluidityproject/fluidity.git

#### USE ONE OF THE TWO FOLLOWING LINES
#FLUIDITY_VERSION=`git ls-remote https://github.com/fluidityproject/fluidity.git master | awk '{print substr($1,1,6);}'`
FLUIDITY_VERSION="c6c026d"

FLUIDITY_BUILDROOT=${PREFIX}/builds/fluidity/${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}
FLUIDITY_SOURCEDIR=${FLUIDITY_BUILDROOT}/fluidity-${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}
FLUIDITY_BUILDDIR=${FLUIDITY_SOURCEDIR}
FLUIDITY_INSTALLDIR=${PREFIX}/models/ese-fluidity/${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}

# Archive any existing source tree
if [ -d ${FLUIDITY_BUILDROOT} ] ; then
  mv ${FLUIDITY_BUILDROOT} ${FLUIDITY_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${FLUIDITY_BUILDDIR}
mkdir -p ${FLUIDITY_INSTALLDIR}

# Fetch and unpack a new source
pushd ${FLUIDITY_BUILDROOT}
git clone ${FLUIDITY_GIT_URL} fluidity-${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}

# Change into the build directory
pushd ${FLUIDITY_BUILDDIR}
git reset --hard ${FLUIDITY_VERSION}

# Set TMPDIR For h5hut
export TMPDIR=${PREFIX}/tmp


#### CHANGE THE PATCH LOCATION TO YOUR PATCH DIRECTORY
#
# Local changes against Fluidity master at #c6c026d
patch -p0 < ${PREFIX}/vtk9-meshio.patch
patch -p0 < ${PREFIX}/use-local-netcdf.patch
patch -p0 < ${PREFIX}/vtk-add-libs.patch
patch -p0 < ${PREFIX}/vtk-add-tools-libs.patch
patch -p0 < ${PREFIX}/vtk-add-fldecomp-libs.patch

# Regenerate configure after local changes
autoconf
pushd libadaptivity
  autoconf
popd

# A bit of prep
libtoolize

# Configure

export LIBS="${LIBS} -L${PETSC_DIR}/lib -lblas -llapack"

${FLUIDITY_SOURCEDIR}/configure --prefix=${FLUIDITY_INSTALLDIR} \
      --enable-2d-adaptivity


#### REMOVE THE INSTALL AND LATER SCRIPT IF YOU WANT TO RUN FROM
#### LOCAL DIRECTORY

# Build and install
make -j 8 && make -j 8 fltools && make install

popd
popd

# Make a copy of this script for future reference

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SCRIPT_NAME="$(basename $SOURCE)"

cp ${SCRIPT_DIR}/${SCRIPT_NAME} \
   ${FLUIDITY_INSTALLDIR}/build-ese-fluidity-${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}.sh

# Write module 

mkdir -p ${PREFIX}/modules/ese-fluidity

cat > ${PREFIX}/modules/ese-fluidity/${FLUIDITY_VERSION}${FLUIDITY_SUFFIX} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${FLUIDITY_INSTALLDIR}

module load ese-fluidity-dev/20200227-python3

setenv           FLUIDITY_HOME \${basedir}
prepend-path     PATH \${basedir}/bin 
prepend-path     PYTHONPATH \${basedir}/lib/python3.7/site-packages
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
