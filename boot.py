# boot.py

# disable debug output
import esp
esp.osdebug(None)

def do_connect():
    import network

    # wifi settings
    wifi_ssid = 'enter ssid'
    wifi_pass = 'and your passphrase'

    sta_if = network.WLAN(network.STA_IF)
    if not sta_if.isconnected():
        print('connecting to network...')
        sta_if.active(True)
        sta_if.connect(wifi_ssid, wifi_pass)
        while not sta_if.isconnected():
            pass
    print('network config:', sta_if.ifconfig())


do_connect()
