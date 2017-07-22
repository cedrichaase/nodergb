-- define pins
PIN_0_RED   = 1
PIN_0_GREEN = 2
PIN_0_BLUE  = 3

PIN_1_RED   = 5
PIN_1_GREEN = 6
PIN_1_BLUE  = 7


-- LED PWM settings (1-1000)
PWM_FREQ = 500

-- WIFI settings
WIFI_SSID = "ssid"
WIFI_PASS = "changeme"

-- RGB Service settings
SERVICE_UDP_PORT = 1337
SERVICE_TCP_PORT = 1338

-- trims a string
function string_trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- splits a string
function string_split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

-- sets the duty cycle with a max value of 255
set_duty_8bit = function(pin, duty)
    if duty == nil then return end
    pwm.setduty(pin, duty * 4)
end

set_color = function(addr, red, green, blue)
    if addr == 0 then
        set_duty_8bit(PIN_0_RED, red)
        set_duty_8bit(PIN_0_GREEN, green)
        set_duty_8bit(PIN_0_BLUE, blue)
    elseif addr == 1 then
        set_duty_8bit(PIN_1_RED, red)
        set_duty_8bit(PIN_1_GREEN, green)
        set_duty_8bit(PIN_1_BLUE, blue)
    elseif addr == 2 then
        set_duty_8bit(PIN_0_RED, red)
        set_duty_8bit(PIN_0_GREEN, green)
        set_duty_8bit(PIN_0_BLUE, blue)
        set_duty_8bit(PIN_1_RED, red)
        set_duty_8bit(PIN_1_GREEN, green)
        set_duty_8bit(PIN_1_BLUE, blue)
    end
end

-- parse, convert and set a color in hex format (e.g. f1c2d0, fc0, e)
set_color_hex = function(addr, hexcolor)
    if hexcolor == nil then return end

    local length = string.len(hexcolor)

    r, g, b = 0, 0, 0
    
    if length == 6 then
        r = string.sub(hexcolor, 1, 2)
        g = string.sub(hexcolor, 3, 4)
        b = string.sub(hexcolor, 5, 6)
    elseif length == 3 then
        r = string.rep(string.sub(hexcolor, 1, 1), 2)
        g = string.rep(string.sub(hexcolor, 2, 2), 2)
        b = string.rep(string.sub(hexcolor, 3, 3), 2)
    elseif length == 1 then
        local c = string.rep(string.sub(hexcolor, 1, 1), 2)
        r, g, b = c, c, c
    end

    r, g, b = tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
    set_color(addr, r, g, b)
end


-- setup pwms
pwm.setup(PIN_0_RED,   PWM_FREQ, 0)
pwm.setup(PIN_0_GREEN, PWM_FREQ, 0)
pwm.setup(PIN_0_BLUE,  PWM_FREQ, 0)
pwm.start(PIN_0_RED)
pwm.start(PIN_0_GREEN)
pwm.start(PIN_0_BLUE)

pwm.setup(PIN_1_RED,   PWM_FREQ, 0)
pwm.setup(PIN_1_GREEN, PWM_FREQ, 0)
pwm.setup(PIN_1_BLUE,  PWM_FREQ, 0)
pwm.start(PIN_1_RED)
pwm.start(PIN_1_GREEN)
pwm.start(PIN_1_BLUE)

-- set color to warm white
set_color_hex(2, 'ff8a14');

-- setup wifi
wifi.setmode(wifi.STATION)
wifi.sta.config(WIFI_SSID, WIFI_PASS)

-- setup udp service
socket=net.createUDPSocket()
socket:on("receive", function(sck, payload)
    payload = string_split(string_trim(payload), ':')
    if payload[2] then
        set_color_hex(tonumber(payload[1]), payload[2])
    else
        set_color_hex(2, payload[1])
    end
end)
socket:listen(SERVICE_UDP_PORT)

-- setup tcp service
server=net.createServer(net.TCP)
server:listen(SERVICE_TCP_PORT, function(conn)
    payload = string_trim(payload)
    if payload == "q" then conn:close(); return end 
    
    payload = string_split(payload, ':')
    if payload[2] then
        set_color_hex(tonumber(payload[1]), payload[2])
    else
        set_color_hex(2, payload[1])
    end
end)
