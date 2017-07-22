#!/bin/bash
BIN=./esp8266-20170612-v1.9.1.bin
DEV=/dev/ttyUSB0

# check requirements
which esptool.py || exit 1
which ampy || exit 1

# erase and flash
esptool.py --port="$DEV" erase_flash
esptool.py --port="$DEV" write_flash -fm=dio -fs=4MB 0x00000 $BIN

# install files
#ampy --port $DEV put boot.py
#ampy --port $DEV put main.py
