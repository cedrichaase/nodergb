#!/bin/bash

which esptool.py || exit 1

esptool.py --port=/dev/cu.wchusbserial1420 erase_flash
esptool.py --port=/dev/cu.wchusbserial1420 write_flash -fm=dio -fs=32m 0x00000 ./nodemcu-master-9-modules-2017-05-10-13-11-01-float.bin

