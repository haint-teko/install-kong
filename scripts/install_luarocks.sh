#!/usr/bin/env bash

apt-get install -y \
    build-essential \
    libreadline-dev \
    wget

wget https://luarocks.github.io/luarocks/releases/luarocks-2.4.3.tar.gz
tar -zxf luarocks-2.4.3.tar.gz

cd ./luarocks-2.4.3

./configure \
    --lua-suffix=jit \
    --with-lua=/usr/local/openresty/luajit \
    --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1
make build
make install

cd .. && rm -rf luarocks-2.4.3*
