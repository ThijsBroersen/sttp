#!/usr/bin/env bash

# From https://github.com/scala-native/scala-native/blob/master/scripts/travis_setup.sh + install curl

# Enable strict mode and fail the script on non-zero exit code,
# unresolved variable or pipe failure.
set -euo pipefail
IFS=$'\n\t'

if [ "$(uname)" == "Darwin" ]; then

    brew update
    brew install sbt
    brew install bdw-gc
    brew link bdw-gc
    brew install jq
    brew install re2
    brew install llvm@4
    export PATH="/usr/local/opt/llvm@4/bin:$PATH"

else

    sudo apt-get update

    # Remove pre-bundled libunwind
    sudo find /usr -name "*libunwind*" -delete

    # Use pre-bundled clang
    export PATH=/usr/local/clang-5.0.0/bin:$PATH
    export CXX=clang++

    # Install Boehm GC and libunwind
    sudo apt-get install libgc-dev libunwind8-dev curl

    # Build and install re2 from source
    git clone https://code.googlesource.com/re2
    pushd re2
    git checkout 2017-03-01
    make -j4 test
    sudo make install prefix=/usr
    make testinstall prefix=/usr
    popd

    ## CURL

    # Get latest (as of Jul 24, 2018) libcurl
    mkdir ~/curl
    cd ~/curl
    wget http://curl.haxx.se/download/curl-7.61.0.tar.bz2
    tar -xvjf curl-7.61.0.tar.bz2
    cd curl-7.61.0

    # The usual steps for building an app from source
    # ./configure
    # ./make
    # sudo make install
    ./configure
    make
    sudo make install

    # Resolve any issues of C-level lib
    # location caches ("shared library cache")
    sudo ldconfig

fi