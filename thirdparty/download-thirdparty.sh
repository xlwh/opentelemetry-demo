#!/bin/bash

#set -e
################################################################
# This script will download all thirdparties and java libraries
# which are defined in *vars.sh*, unpack patch them if necessary.
# You can run this script multi-times.
# Things will only be downloaded, unpacked and patched once.
################################################################

curdir=`dirname "$0"`
curdir=`cd "$curdir"; pwd`

if [[ -z "${STARROCKS_HOME}" ]]; then
    STARROCKS_HOME=$curdir/..
fi

# include custom environment variables
if [[ -f ${STARROCKS_HOME}/custom_env.sh ]]; then
    . ${STARROCKS_HOME}/custom_env.sh
fi

if [[ -z "${TP_DIR}" ]]; then
    TP_DIR=$curdir
fi

if [ ! -f ${TP_DIR}/vars.sh ]; then
    echo "vars.sh is missing".
    exit 1
fi
. ${TP_DIR}/vars.sh

mkdir -p ${TP_DIR}/src

md5sum_bin=md5sum
if ! command -v ${md5sum_bin} >/dev/null 2>&1; then
    echo "Warn: md5sum is not installed"
    md5sum_bin=""
fi

md5sum_func() {
    local FILENAME=$1
    local DESC_DIR=$2
    local MD5SUM=$3

    if [ "$md5sum_bin" == "" ]; then
       return 0
    else
       md5=`md5sum "$DESC_DIR/$FILENAME"`
       if [ "$md5" != "$MD5SUM  $DESC_DIR/$FILENAME" ]; then
           echo "$DESC_DIR/$FILENAME md5sum check failed!"
           echo -e "except-md5 $MD5SUM \nactual-md5 $md5"
           return 1
       fi
    fi

    return 0
}

download_func() {
    local FILENAME=$1
    local DOWNLOAD_URL=$2
    local DESC_DIR=$3
    local MD5SUM=$4

    if [ -z "$FILENAME" ]; then
        echo "Error: No file name specified to download"
        exit 1
    fi
    if [ -z "$DOWNLOAD_URL" ]; then
        echo "Error: No download url specified for $FILENAME"
        exit 1
    fi
    if [ -z "$DESC_DIR" ]; then
        echo "Error: No dest dir specified for $FILENAME"
        exit 1
    fi


    SUCCESS=0
    for attemp in 1 2; do
        if [ -r "$DESC_DIR/$FILENAME" ]; then
            if md5sum_func $FILENAME $DESC_DIR $MD5SUM; then
                echo "Archive $FILENAME already exist."
                SUCCESS=1
                break;
            fi
            echo "Archive $FILENAME will be removed and download again."
            rm -f "$DESC_DIR/$FILENAME"
        else
            echo "Downloading $FILENAME from $DOWNLOAD_URL to $DESC_DIR"
            wget --no-check-certificate $DOWNLOAD_URL -O $DESC_DIR/$FILENAME
            if [ "$?"x == "0"x ]; then
                if md5sum_func $FILENAME $DESC_DIR $MD5SUM; then
                    SUCCESS=1
                    echo "Success to download $FILENAME"
                    break;
                fi
                echo "Archive $FILENAME will be removed and download again."
                rm -f "$DESC_DIR/$FILENAME"
            else
                echo "Failed to download $FILENAME. attemp: $attemp"
            fi
        fi
    done

    if [ $SUCCESS -ne 1 ]; then
        echo "Failed to download $FILENAME"
    fi
    return $SUCCESS
}

# download thirdparty archives
echo "===== Downloading thirdparty archives..."
for TP_ARCH in ${TP_ARCHIVES[*]}
do
    NAME=$TP_ARCH"_NAME"
    MD5SUM=$TP_ARCH"_MD5SUM"
    if test "x$REPOSITORY_URL" = x; then
        URL=$TP_ARCH"_DOWNLOAD"
        download_func ${!NAME} ${!URL} $TP_SOURCE_DIR ${!MD5SUM}
        if [ "$?"x == "0"x ]; then
            echo "Failed to download ${!NAME}"
            exit 1
        fi
    else
        URL="${REPOSITORY_URL}/${!NAME}"
        download_func ${!NAME} ${URL} $TP_SOURCE_DIR ${!MD5SUM}
        if [ "$?x" == "0x" ]; then
            #try to download from home
            URL=$TP_ARCH"_DOWNLOAD"
            download_func ${!NAME} ${!URL} $TP_SOURCE_DIR ${!MD5SUM}
            if [ "$?x" == "0x" ]; then
                echo "Failed to download ${!NAME}"
                exit 1 # download failed again exit.
            fi
        fi
    fi
done
echo "===== Downloading thirdparty archives...done"

# check if all tp archievs exists
echo "===== Checking all thirdpart archives..."
for TP_ARCH in ${TP_ARCHIVES[*]}
do
    NAME=$TP_ARCH"_NAME"
    if [ ! -r $TP_SOURCE_DIR/${!NAME} ]; then
        echo "Failed to fetch ${!NAME}"
        exit 1
    fi
done
echo "===== Checking all thirdpart archives...done"

# unpacking thirdpart archives
echo "===== Unpacking all thirdparty archives..."
TAR_CMD="tar"
UNZIP_CMD="unzip"
SUFFIX_TGZ="\.(tar\.gz|tgz)$"
SUFFIX_XZ="\.tar\.xz$"
SUFFIX_ZIP="\.zip$"
# temporary directory for unpacking
# package is unpacked in tmp_dir and then renamed.
mkdir -p $TP_SOURCE_DIR/tmp_dir
for TP_ARCH in ${TP_ARCHIVES[*]}
do
    NAME=$TP_ARCH"_NAME"
    SOURCE=$TP_ARCH"_SOURCE"

    if [ -z "${!SOURCE}" ]; then
        continue
    fi

    if [ ! -d $TP_SOURCE_DIR/${!SOURCE} ]; then
        if [[ "${!NAME}" =~ $SUFFIX_TGZ  ]]; then
            echo "$TP_SOURCE_DIR/${!NAME}"
            echo "$TP_SOURCE_DIR/${!SOURCE}"
            echo $TAR_CMD xzf "$TP_SOURCE_DIR/${!NAME}" -C $TP_SOURCE_DIR/tmp_dir
            if ! $TAR_CMD xzf "$TP_SOURCE_DIR/${!NAME}" -C $TP_SOURCE_DIR/tmp_dir; then
                echo "Failed to untar ${!NAME}"
                exit 1
            fi
        elif [[ "${!NAME}" =~ $SUFFIX_XZ ]]; then
            echo "$TP_SOURCE_DIR/${!NAME}"
            echo "$TP_SOURCE_DIR/${!SOURCE}"
            if ! $TAR_CMD xJf "$TP_SOURCE_DIR/${!NAME}" -C $TP_SOURCE_DIR/tmp_dir; then
                echo "Failed to untar ${!NAME}"
                exit 1
            fi
        elif [[ "${!NAME}" =~ $SUFFIX_ZIP ]]; then
            if ! $UNZIP_CMD "$TP_SOURCE_DIR/${!NAME}" -d $TP_SOURCE_DIR/tmp_dir; then
                echo "Failed to unzip ${!NAME}"
                exit 1
            fi
        else
            echo "nothing has been done with ${!NAME}"
            continue
        fi
        mv $TP_SOURCE_DIR/tmp_dir/* $TP_SOURCE_DIR/${!SOURCE}
    else
        echo "${!SOURCE} already unpacked."
    fi
done
rm -r $TP_SOURCE_DIR/tmp_dir
echo "===== Unpacking all thirdparty archives...done"

