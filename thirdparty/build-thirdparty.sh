#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

#################################################################################
# This script will
# 1. Check prerequisite libraries. Including:
#    cmake byacc flex automake libtool binutils-dev libiberty-dev bison
# 2. Compile and install all thirdparties which are downloaded
#    using *download-thirdparty.sh*.
#
# This script will run *download-thirdparty.sh* once again
# to check if all thirdparties have been downloaded, unpacked and patched.
#################################################################################
set -e

curdir=`dirname "$0"`
curdir=`cd "$curdir"; pwd`

export STARROCKS_HOME=$curdir
export TP_DIR=$curdir

# include custom environment variables
if [[ -f ${STARROCKS_HOME}/env.sh ]]; then
    . ${STARROCKS_HOME}/env.sh
fi

if [[ ! -f ${TP_DIR}/download-thirdparty.sh ]]; then
    echo "Download thirdparty script is missing".
    exit 1
fi

if [ ! -f ${TP_DIR}/vars.sh ]; then
    echo "vars.sh is missing".
    exit 1
fi
. ${TP_DIR}/vars.sh

cd $TP_DIR

# Download thirdparties.
${TP_DIR}/download-thirdparty.sh

export C_INCLUDE_PATH=${TP_INCLUDE_DIR}:${C_INCLUDE_PATH}
export CPLUS_INCLUDE_PATH=${TP_INCLUDE_DIR}:${CPLUS_INCLUDE_PATH}
export LD_LIBRARY_PATH=$TP_DIR/installed/lib:$LD_LIBRARY_PATH

# prepare installed prefix
mkdir -p ${TP_DIR}/installed

check_prerequest() {
    local CMD=$1
    local NAME=$2
    if ! $CMD; then
        echo $NAME is missing
        exit 1
    else
        echo $NAME is found
    fi
}

#########################
# build all thirdparties
#########################

# Name of cmake build directory in each thirdpary project.
# Do not use `build`, because many projects contained a file named `BUILD`
# and if the filesystem is not case sensitive, `mkdir` will fail.
BUILD_DIR=starrocks_build
MACHINE_TYPE=$(uname -m)

check_if_source_exist() {
    if [ -z $1 ]; then
        echo "dir should specified to check if exist."
        exit 1
    fi

    if [ ! -d $TP_SOURCE_DIR/$1 ];then
        echo "$TP_SOURCE_DIR/$1 does not exist."
        exit 1
    fi
    echo "===== begin build $1"
}

check_if_archieve_exist() {
    if [ -z $1 ]; then
        echo "archieve should specified to check if exist."
        exit 1
    fi

    if [ ! -f $TP_SOURCE_DIR/$1 ];then
        echo "$TP_SOURCE_DIR/$1 does not exist."
        exit 1
    fi
}

# opentelemetry
build_opentelemetry() {
    check_if_source_exist $OPENTELEMETRY_SOURCE

    cd $TP_SOURCE_DIR/$OPENTELEMETRY_SOURCE
    mkdir -p $BUILD_DIR
    cd $BUILD_DIR
    rm -rf CMakeCache.txt CMakeFiles/
    cmake -DCMAKE_INSTALL_PREFIX=${TP_INSTALL_DIR} -DCMAKE_INSTALL_LIBDIR=lib64 ..
    make -j$PARALLEL
    make install
}

export CXXFLAGS="-O3 -fno-omit-frame-pointer -Wno-class-memaccess -fPIC -g -I${TP_INCLUDE_DIR}"
export CPPFLAGS=$CXXFLAGS
# https://stackoverflow.com/questions/42597685/storage-size-of-timespec-isnt-known
export CFLAGS="-O3 -fno-omit-frame-pointer -std=c99 -fPIC -g -D_POSIX_C_SOURCE=199309L -I${TP_INCLUDE_DIR}"

build_opentelemetry

echo "Finished to build all thirdparties"

