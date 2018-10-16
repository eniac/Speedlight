#!/bin/bash

set -e 

# install rules
./third_party/behavioral-model/targets/speedlight_switch/sswitch_CLI --thrift-port 9090 < out/commands.txt
