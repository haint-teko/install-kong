#!/usr/bin/env bash
# install decision-maker plugin

cd ./plugins/decision-maker
luarocks make > /dev/null 2>&1
luarocks make
cd ../..
