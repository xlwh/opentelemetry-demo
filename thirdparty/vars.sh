#!/bin/bash

############################################################
# You may have to set variables bellow,
# which are used for compiling thirdparties and starrocks itself.
############################################################

# --job param for *make*
PARALLEL=4

###################################################
# DO NOT change variables bellow unless you known
# what you are doing.
###################################################

# thirdparties will be downloaded and unpacked here
export TP_SOURCE_DIR=$TP_DIR/src

# thirdparties will be installed to here
export TP_INSTALL_DIR=$TP_DIR/installed

# patches for all thirdparties
export TP_PATCH_DIR=$TP_DIR/patches

# header files of all thirdparties will be intalled to here
export TP_INCLUDE_DIR=$TP_INSTALL_DIR/include

# libraries of all thirdparties will be intalled to here
export TP_LIB_DIR=$TP_INSTALL_DIR/lib

# all java libraries will be unpacked to here
export TP_JAR_DIR=$TP_INSTALL_DIR/lib/jar

#####################################################
# Download url, filename and unpacked filename
# of all thirdparties
#####################################################

# Definitions for architecture-related thirdparty
MACHINE_TYPE=$(uname -m)
VARS_TARGET=vars-${MACHINE_TYPE}.sh

if [ ! -f ${TP_DIR}/${VARS_TARGET} ]; then
    echo "${VARS_TARGET} is missing".
    exit 1
fi
. ${TP_DIR}/${VARS_TARGET}

# open-telemetry
# the last release version of libevent is 2.1.8, which was released on 26 Jan 2017, that is too old.
# so we use the master version of libevent, which is downloaded on 22 Jun 2018, with commit 24236aed01798303745470e6c498bf606e88724a
OPENTELEMETRY_DOWNLOAD="https://github.com/open-telemetry/opentelemetry-cpp/archive/refs/tags/v1.2.0.tar.gz"
OPENTELEMETRY_NAME=v1.2.0.tar.gz
OPENTELEMETRY_SOURCE=opentelemetry-cpp-1.2.0
OPENTELEMETRY_MD5SUM="c084abc742c6b3cd4c9c3684e559d4e1"

# all thirdparties which need to be downloaded is set in array TP_ARCHIVES
TP_ARCHIVES="OPENTELEMETRY"
