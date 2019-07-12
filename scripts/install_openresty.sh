#!/usr/bin/env bash

apt-get install -y \
    libpcre3-dev \
    libssl-dev \
    perl \
    make \
    build-essential \
    curl \
    zlib1g-dev \
    wget

wget https://openresty.org/download/openresty-1.13.6.2.tar.gz
tar -xvf openresty-1.13.6.2.tar.gz

cd ./openresty-1.13.6.2
./configure \
    --with-pcre-jit \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_v2_module
make
make install

rm -rf openresty-1.13.6.2*

echo "export PATH=/usr/local/openresty/bin:$PATH" >> /etc/bash.bashrc
