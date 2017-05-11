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
SERVICE_UDP_PORT = 1337
SERVICE_TCP_PORT = 1338

-- trims a string
function string_trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- sets the duty cycle with a max value of 255
set_duty_8bit = function(pin, duty)
    if duty == nil then return end
    pwm.setduty(pin, duty * 4)
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
    
    if length == 6 then
        r = string.sub(hexcolor, 1, 2)
        g = string.sub(hexcolor, 3, 4)
        b = string.sub(hexcolor, 5, 6)
    elseif length == 3 then
        r = string.rep(string.sub(hexcolor, 1, 1), 2)
        g = string.rep(string.sub(hexcolor, 2, 2), 2)
        b = string.rep(string.sub(hexcolor, 3, 3), 2)
    elseif length == 1 then
        hexcolor = string.sub(hexcolor, 1, 1)
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

-- setup udp service
socket=net.createUDPSocket()
socket:on("receive", function(sck, payload)
    set_color_hex(string_trim(payload))
end)
socket:listen(SERVICE_UDP_PORT)

-- setup tcp service
server=net.createServer(net.TCP)
server:listen(SERVICE_TCP_PORT, function(conn)
    conn:on("receive", function(conn, payload)
        payload = string_trim(payload)
        if payload == "q" then conn:close(); return end 
        set_color_hex(payload)
    end)
end)
