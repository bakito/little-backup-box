#!/usr/bin/python
#!python

import time

import Adafruit_GPIO.SPI as SPI
import Adafruit_SSD1306

from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

import subprocess

import sys, os

pathname = os.path.dirname(sys.argv[0])
abspath = os.path.abspath(pathname) + "/"

# Raspberry Pi pin configuration:
RST = None     # on the PiOLED this pin isnt used
# Note the following are only used with SPI:
DC = 23
SPI_PORT = 0
SPI_DEVICE = 0

# 128x64 display with hardware I2C:
disp = Adafruit_SSD1306.SSD1306_128_64(rst=RST)

# Initialize library.
disp.begin()

# Create blank image for drawing.
# Make sure to create image with mode '1' for 1-bit color.
width = disp.width
height = disp.height
image = Image.new('1', (width, height))

# Get drawing object to draw on image.
draw = ImageDraw.Draw(image)

# Draw a black filled box to clear the image.
draw.rectangle((0,0,width,height), outline=0, fill=0)

# Draw some shapes.
# First define some constants to allow easy resizing of shapes.
padding = -2
top = padding
bottom = height-padding
# Move left to right keeping track of the current x position for drawing shapes.
x = 0


# Load default font.
font = ImageFont.load_default()

# Alternatively load a TTF font.  Make sure the .ttf font file is in the same directory as the python script!
# Some other nice fonts to try: http://www.dafont.com/bitmap.php
fa_brands_20  = ImageFont.truetype(abspath + 'fa-brands-400.ttf', 20)
font_text = ImageFont.truetype(abspath + 'Montserrat-Light.ttf', 12)
fa_solid_20   = ImageFont.truetype(abspath + 'fa-solid-900.ttf', 20)

# hourglass: solid 62034
# sdcard: solid 63426
# download: solid 61465
# r-pi: brand 63419
# usb: brands 62087

# Draw a black filled box to clear the image.
draw.rectangle((0,0,width,height), outline=0, fill=0)

# Icon
draw.text((x, top+5), unichr(63426),  font=fa_solid_20, fill=255)
draw.text((x, top+45), unichr(61465),  font=fa_solid_20, fill=255)

# Text
draw.text((30, top+5),    "Card Reader OK",  font=font_text, fill=255)
draw.text((30, top+50),   "Working ...",  font=font_text, fill=255)

# Display image.
disp.image(image)
disp.display()
