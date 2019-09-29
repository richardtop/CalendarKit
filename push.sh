#!/usr/bin/env bash

cd ../
source ~/.rvm/scripts/rvm
rvm use default
pod trunk push --allow-warnings
