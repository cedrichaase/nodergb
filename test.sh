#!/bin/sh

IP=192.168.178.101
PORT=1337
SLEEP_DURATION=0.01

while true; do

    # dim red up and down
    for b in {0..255}; do
        printf "%02x%02x%02x\n" $b 0 0 | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done

    for b in {254..0}; do
        printf "%02x%02x%02x\n" $b 0 0 | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done

    # dim green up and down
    for b in {0..255}; do
        printf "%02x%02x%02x\n" 0 $b 0 | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done

    for b in {254..0}; do
        printf "%02x%02x%02x\n" 0 $b 0 | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done

    # dim blue up and down
    for b in {0..255}; do
        printf "%02x%02x%02x\n" 0 0 $b | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done

    for b in {254..0}; do
        printf "%02x%02x%02x\n" 0 0 $b | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done

    # dim all up and down
    for b in {0..255}; do
        printf "%02x%02x%02x\n" $b $b $b | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done

    for b in {254..0}; do
        printf "%02x%02x%02x\n" $b $b $b | nc -cu $IP $PORT
        sleep $SLEEP_DURATION
    done

done

