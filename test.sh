#!/bin/sh

IP=192.168.178.101
PORT=1337
SLEEP_DURATION=0.05

while true; do
    for brightness in {0..9}; do
        echo "$brightness" | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done
    for brightness in {9..0}; do
        echo "$brightness" | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done
done

