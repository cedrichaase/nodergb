-- define pins
PIN_RED     = 1
PIN_GREEN   = 2
PIN_BLUE    = 3

-- LED PWM settings (1-1000)
PWM_FREQ = 500


-- WIFI settings
WIFI_SSID = "your-ssid-here"
WIFI_PASS = "changeme"

-- RGB Service settings
SERVICE_UDP_PORT = 1338
SERVICE_HTTP_PORT = 80


-- sets the duty cycle with a max value of 255
set_duty_8bit = function(pin, duty)
    local duty_8bit = duty * 3
    pwm.setduty(pin, duty_8bit)
end

set_color = function(red, green, blue)
    set_duty_8bit(PIN_RED, red)
    set_duty_8bit(PIN_GREEN, green)
    set_duty_8bit(PIN_BLUE, blue)
end

-- parse, convert and set a color in hex format (e.g. f1c2d0, fc0, e)
set_color_hex = function(hexcolor)
    if hexcolor == nil then return end

    local length = string.len(hexcolor)

    r, g, b = 0, 0, 0
    
    if length == 7 then
        r = string.sub(hexcolor, 1, 2)
        g = string.sub(hexcolor, 3, 4)
        b = string.sub(hexcolor, 5, 6)

        print(r, g, b)
    elseif length == 4 then
        r = string.rep(string.sub(hexcolor, 1, 1), 2)
        g = string.rep(string.sub(hexcolor, 2, 2), 2)
        b = string.rep(string.sub(hexcolor, 3, 3), 2)
    elseif length == 2 then
        r, g, b = string.rep(hexcolor, 2), string.rep(hexcolor, 2), string.rep(hexcolor, 2)
    end

    r, g, b = tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
    set_color(r, g, b)
end


-- setup pwms
pwm.setup(PIN_RED,   PWM_FREQ, 0)
pwm.setup(PIN_GREEN, PWM_FREQ, 0)
pwm.setup(PIN_BLUE,  PWM_FREQ, 0)
pwm.start(PIN_RED)
pwm.start(PIN_GREEN)
pwm.start(PIN_BLUE)

-- setup wifi
wifi.setmode(wifi.STATION)
wifi.sta.config(WIFI_SSID, WIFI_PASS)

socket=net.createServer(net.UDP)
socket:on("receive", function(sck, payload)
    set_color_hex(payload)
end)
socket:listen(SERVICE_UDP_PORT)
