#!/bin/bash
PORT=/dev/tty.SLAB_USBtoUART

which esptool.py || exit 1

esptool.py --port="${PORT}" erase_flash
esptool.py --port="${PORT}" write_flash -fm=dio -fs=32m 0x00000 ./nodemcu-master-9-modules-2017-05-10-13-11-01-float.bin

