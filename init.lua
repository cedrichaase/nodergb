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
WIFI_SSID = "changeme"
WIFI_PASS = "changeme"

-- MQTT settings
MQTT_BROKER_HOST = "rainboschwan"
MQTT_TOPIC_PREFIX = "cedric/light1"

-- subscribe to mqtt topics
STATE_TOPIC = MQTT_TOPIC_PREFIX .. "/state"
COMMAND_TOPIC = MQTT_TOPIC_PREFIX .. "/switch"


-- color state / initial colors
RED = 255
GREEN = 138
BLUE = 20


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

publish_rgb_state = function(client)
    local payload = RED .. "," .. GREEN .. "," .. BLUE
    client:publish("rgb_state_topic", payload, 0, 1)
    print("published " .. payload)
end

publish_state = function(client)
    -- fixme
    local payload = "ON"
    if RED == 0 then
        payload = "OFF"
    end

    client:publish(STATE_TOPIC, payload, 0, 1)
    print("published " .. payload)
end

set_color = function(addr, red, green, blue)
    print("set_color(" .. addr .. ", " .. red .. ", " .. green .. ", " .. blue .. ")")

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

    RED = red
    GREEN = green
    BLUE = blue
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
set_color(2, RED, GREEN, BLUE);


-- setup wifi
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=WIFI_SSID, pwd=WIFI_PASS, got_ip_cb=(function()
    print("got ip: " .. wifi.sta.getip())

    mqtt_client = mqtt.Client("clientid", 120)

    mqtt_client:connect(MQTT_BROKER_HOST, 1883, 0, function(client)
      print("connected")



      client:subscribe(COMMAND_TOPIC, 0, function(client)
        print("subscribed to " .. COMMAND_TOPIC)
      end)


      -- handle messages
      client:on("message", function(client, topic, message)
        local payload = string_split(string_trim(message), ':')

        -- handle state change
        if topic == "rgb_command_topic" then
          print("received state msg " .. message)
          local rgb = string_split(string_trim(message), ',')

          set_color(2, tonumber(rgb[1]), tonumber(rgb[2]), tonumber(rgb[3]))
        end

        -- handle on/off commands
        if topic == COMMAND_TOPIC then
          local command = string_trim(message)

          print("received command " .. command)

          if command == "ON" then
            set_color(2, 255, 138, 20)
          elseif command == "OFF" then
            set_color(2, 0, 0, 0)
          end

          publish_state(client)
        end


      end)
    end,
    function(client, reason)
        print("MQTT connection failed, reason: " .. reason)
    end)
end)})
