#!/usr/bin/env bash

set -e

if [ "$0" != "./scripts/build-release.sh" ]; then
    echo "'build-release.sh' should be run from repository root"
    exit 1
fi

function usage(){
  >&2 echo "
 Usage:
    $0 [version]

 Ex:
    $0 0+dev.1
"
  exit 1
}

if [ "$1" == "-h" ] || [ "$1" == "--help"  ] || [ "$1" == "help"  ]; then
    usage
fi


if [ "$#" -gt 0 ]; then
    if [ -e "$1" ]; then
        export version=`cat $1`
    else
        export version=$1
    fi
fi

echo "Building splunk-firehose-nozzle-release ${version}"
echo ""

echo "Cleaning up blobs"
rm -rf .blobs/* blobs/*
echo "--- {} " > config/blobs.yml

echo "Downloading binaries"

mkdir -p tmp

export go_pkg_path=./tmp/go-linux-amd64.tar.gz
export go_version_path=./tmp/go-version.txt
export go_pkg_remote=https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz

export splunk_pkg_path=./tmp/splunk-linux-x86_64.tgz
export splunk_version_path=./tmp/splunk-version.txt
export splunk_pkg_remote=https://download.splunk.com/products/splunk/releases/6.5.3/linux/splunk-6.5.3-36937ad027d4-Linux-x86_64.tgz

if [ -a "${go_pkg_path}" ]; then
    echo "Go package already exist, skipping download"
else
    echo "Go package doesn't exist, downloading"
    wget "${go_pkg_remote}" -O "${go_pkg_path}"
fi
echo "${go_pkg_remote}" > "${go_version_path}"

if [ -a "${splunk_pkg_path}" ]; then
    echo "Splunk package already exist, skipping download"
else
    echo "Splunk pagage doesn't exist, downloading"
    wget "${splunk_pkg_remote}" -O "${splunk_pkg_path}"
fi
echo "${splunk_pkg_remote}" > "${splunk_version_path}"

echo "Adding blobs"
bosh add-blob "${go_pkg_path}" golang
bosh add-blob "${go_version_path}" golang
bosh add-blob "${splunk_pkg_path}" splunk
bosh add-blob "${splunk_version_path}" splunk

echo "Creating release"
create_cmd="bosh create-release --name cf-splunk --tarball cf-splunk-${version}.tgz  "
if [ "$version" != "" ]; then
    create_cmd+=" --version "${version}""
fi

echo $create_cmd
eval ${create_cmd}
