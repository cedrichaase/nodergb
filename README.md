# NodeRGB
A simple script for controlling RGB LEDs with [NodeMCU](http://nodemcu.com/index_en.html)

## Prerequisites
You will need a means to flash the firmware binary to your ESP. Install esptool and ampy using `pip`

```
# pip install esptool
# pip3 install adafruit-ampy
```

## Install firmware
Connect a NodeMCU to your computer. Then, in `flash.sh`, edit the esptool.py `DEV` constant to point to the NodeMCU serial port.

Now, execute flash.sh to flash the firmware binary:

```
$ ./flash.sh
```

Edit `boot.py` and change the `WIFI_SSID` and `WIFI_PASS` variables to whatever the login credentials for your wireless network are.

## Integrity check
First, get a python REPL on the NodeMCU using picocom:

```
$ picocom -b 115200 /dev/ttyUSB0
```

Then enter two lines of python code to verify firmware integrity:

```
>>> import esp
>>> esp.check_fw()
size: 598416
md5: dae90ece36362127bce73f27cefe47fd
True
```

Close picocom by `Ctrl+b` followed by a `Ctrl+x`.

## Upload python code
Finally install both python scripts using `ampy`:

```
ampy --port $DEV put boot.py
ampy --port $DEV put main.py
```

After reset, the NodeMCU will first run boot.py and then main.py. Congrats, you're done!

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
