# NodeRGB

A simple script for controlling RGB LEDs with [NodeMCU](http://nodemcu.com/index_en.html)

## Prerequisites

You will need a means to flash the firmware binary to your ESP. Install esptool.py using `pip`

```
# pip install esptool
```

Also, you will have to persist the `init.lua` script to the ESP's flash memory. This can be done either by writing lua code manually to the serial port of the ESP or preferably by using a tool like [ESPlorer](https://github.com/4refr0nt/ESPlorer).


## Setup

Connect a NodeMCU to your computer. Then, in `flash.sh`, edit the esptool.py `--port` parameter to point to the NodeMCU serial port.

Make sure the device is ready to be flashed. Now, execute flash.sh to flash the firmware binary.

```
$ ./flash.sh
```

Edit `init.lua` and change the `WIFI_SSID` and `WIFI_PASS` variables to whatever the login credentials for your wireless network are.

Using [ESPlorer](https://github.com/4refr0nt/ESPlorer) or any other method, write `init.lua` to your NodeMCU's flash memory.



## Usage

The ESP should now connect to your wireless network every time you power it up. Find out its IP address, either by querying it via serial (`wifi.sta.getip()`), by looking it up on your DHCP server (i.e. router) or performing a host discovery (i.e. `nmap -sP 192.168.1.0/24`).

Now, you can send color data to it using its UDP protocol.

```
nc -u IP-ADDR 1337
```

The data format is defined as follows:

```
<message> ::= [<subnode>:]<hexcolor>\n

<subnode> ::= <id>(\.<id>)*

<id> ::= a-zA-Z0-9

<hexcolor> ::= <hexdigit> | <hexdigit>{3} | <hexdigit>{6}

<hexdigit> ::= 0-9a-fA-F
```

Some simple examples:

`00f` blue

`00ff71` cyan

`f` white

`0` black
