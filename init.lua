-- Library Code

-- String functions
function string_trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string_split(str, delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( str, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( str, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( str, delimiter, from  )
  end
  table.insert( result, string.sub( str, from  ) )
  return result
end


-- LightState class
LightState = {}
LightState.__index = LightState

function LightState.new()
  local self = setmetatable({}, LightState)
  -- modify instance here

  self.red = 255
  self.green = 138
  self.blue = 20

  self.brightness = 255

  self.state = "on"

  return self
end

function LightState.get_rgb(self)
  local function scale_color(color)
    return math.floor(color * self.brightness / 255)
  end

  return {
    r = scale_color(self.red),
    g = scale_color(self.green),
    b = scale_color(self.blue)
  }
end

function LightState.from_string(self, str)
  local parts = string_split(str, ",")

  self.state = parts[1]

  if parts[2] and #parts[2] > 0 then
    print("setting brightness to " .. parts[2])
    self.brightness = tonumber(parts[2])
  end

  if parts[3] and #parts[3] > 2 then
    local rgb = string_split(parts[3], "-")

    if #rgb < 3 then
        return
    end

    self.red = tonumber(rgb[1])
    self.green = tonumber(rgb[2])
    self.blue = tonumber(rgb[3])
  end
end

function LightState.to_string(self)
  local rgb = self:get_rgb()
  local rgbstring = rgb['r'] .. "-" .. rgb['g'] .. "-" .. rgb['b']

  return self.state .. "," .. self.brightness .. "," .. rgbstring
end





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
COMMAND_TOPIC = MQTT_TOPIC_PREFIX .. "/set"


-- setup light states
STATE = LightState.new()


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
    local payload = STATE:to_string()

    client:publish(STATE_TOPIC, payload, 0, 1)
    print("published " .. payload)
end

display_state = function(state)
  if state.state == "off" then
    set_color(0, 0, 0)
    return
  end

  local rgb = state:get_rgb()
  set_color(rgb['r'], rgb['g'], rgb['b'])
end

set_color = function(red, green, blue)
    print("set_color(" .. red .. ", " .. green .. ", " .. blue .. ")")

    set_duty_8bit(PIN_0_RED, red)
    set_duty_8bit(PIN_0_GREEN, green)
    set_duty_8bit(PIN_0_BLUE, blue)
    set_duty_8bit(PIN_1_RED, red)
    set_duty_8bit(PIN_1_GREEN, green)
    set_duty_8bit(PIN_1_BLUE, blue)
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
        -- handle on/off commands
        if topic == COMMAND_TOPIC then
          local payload = string_trim(message)

          print("received payload " .. payload)

          STATE = LightState.new()
          STATE:from_string(payload)
          display_state(STATE)

          publish_state(client)
        end

      end)
    end,
    function(client, reason)
        print("MQTT connection failed, reason: " .. reason)
    end)
end)})
