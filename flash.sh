#!/bin/bash
PORT=/dev/ttyUSB0

which esptool.py || exit 1

esptool.py --port="${PORT}" erase_flash
esptool.py --port="${PORT}" write_flash -fm=dio -fs=4MB 0x00000 ./nodemcu-master-12-modules-2018-08-07-15-59-56-float.bin
