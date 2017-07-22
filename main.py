# main.py

from machine import Pin, PWM

# pin numbering is defined by ESP8266 not the NodeMCU:
# Board-Pin | ESP8266-Pin
# ----------+------------
# 1         | 5
# 2         | 4
# 3         | 0
# 5         | 14
# 6         | 12
# 7         | 13

# setup PWM lists pwm[r,g,b]
pwm_freq = 500

pwm0 = [PWM(Pin(5)), PWM(Pin(4)), PWM(Pin(0))]
pwm1 = [PWM(Pin(14)), PWM(Pin(12)), PWM(Pin(13))]

pwms = [pwm0, pwm1]


def set_color(channel, red, green, blue):
    """Set the color of a given channel.
    Args:
        channel (int): The pwm channel. Must be 0 oder 1.
        red (int): Red brightness from 0 to 1023.
        green (int): Green brightness from 0 to 1023.
        blue (int): Blue brightness from 0 to 1023.
    """
    pwm = pwms[channel]
    pwm[0].duty(red)
    pwm[1].duty(green)
    pwm[2].duty(blue)


def set_hexcolor(channel, hexcolor):
    """Set the color of a given channel using a hexadecimal string
    Args:
        channel (int): The pwm channel. Must be 0 oder 1.
        hexcolor (string): One, two, three or six hexadecimal digits
            representing either the brightness of all colors (one or
            two digits) or the red, green and blue brightness components.
    """
    # parse hexcolor string and set color
    length = len(hexcolor)

    if length is 1:
        # 4-bit brightness
        b = int(hexcolor, 16) << 4
        set_color(channel, b, b, b)

    elif length is 2:
        # 8-bit brightness
        b = int(hexcolor, 16)
        set_color(channel, b, b, b)

    elif length is 3:
        # 12-bit rgb
        r = int(hexcolor[0], 16) << 4
        g = int(hexcolor[1], 16) << 4
        b = int(hexcolor[2], 16) << 4
        set_color(channel, r, g, b)

    elif length is 6:
        # 24-bit rgb
        r = int(hexcolor[:2], 16)
        g = int(hexcolor[2:-2], 16)
        b = int(hexcolor[-2:], 16)
        set_color(channel, r, g, b)

    else:
        print('Invalid hexcolor string')


# set color to warm white
set_hexcolor(0, 'ff8a14')
set_hexcolor(1, 'ff8a14')
