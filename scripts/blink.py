#!/usr/bin/python
#!python

import RPi.GPIO as GPIO
import sys
import time

rgb = "000"
if (len(sys.argv) > 1 and len(sys.argv[1]) == 3):
  rgb = sys.argv[1]

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

RED = 25
GREEN = 24
BLUE = 23

GPIO.setup(RED,GPIO.OUT)
GPIO.setup(GREEN,GPIO.OUT)
GPIO.setup(BLUE,GPIO.OUT)


while True:
  GPIO.output(RED,int(rgb[0]))
  GPIO.output(GREEN,int(rgb[1]))
  GPIO.output(BLUE,int(rgb[2]))
  time.sleep(0.5)

  GPIO.output(RED,0)
  GPIO.output(GREEN,0)
  GPIO.output(BLUE,0)
  time.sleep(0.5)

