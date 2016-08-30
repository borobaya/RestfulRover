#!/usr/bin/env python
# -*- coding: utf-8 -*-

from RPi import GPIO
import logger

motor_freq = 50 # Motor PWM frequency in Hz

class Hardware():
    """Hardware"""
    def __init__(self, name, hardware_type, \
        is_writable=False, value_type="binary", \
        value_min=0, value_max=1, value=0, args={}):
        self.name = name
        self.hardware_type = hardware_type
        self.is_writable = is_writable
        self.value_type = value_type # "continous", "discrete", "binary"
        self.value = value
        self.value_min = value_min
        self.value_max = value_max
        if hardware_type=="motor": # TODO: gracefully handle errors (i.e. validate input)
            self.pinControl = int(args['pinControl'])
            self.pinForward = int(args['pinForward'])
            self.pinBackward = int(args['pinBackward'])
            if not self.pinControl==self.pinForward==self.pinBackward==0:
                logger.info("Using pin " + str(self.pinControl))
                GPIO.setup(self.pinControl, GPIO.OUT)
                self.pwm = GPIO.PWM(self.pinControl, motor_freq)
                logger.info("Using pin " + str(self.pinForward))
                GPIO.setup(self.pinForward, GPIO.OUT)
                logger.info("Using pin " + str(self.pinBackward))
                GPIO.setup(self.pinBackward, GPIO.OUT)

    def updatePins(self):
        if self.hardware_type=="motor" and not self.pinControl==self.pinForward==self.pinBackward==0:
            if self.value==0:
                # GPIO.output(self.pinControl, GPIO.LOW)
                self.pwm.stop()
                GPIO.output(self.pinForward, GPIO.LOW)
                GPIO.output(self.pinBackward, GPIO.LOW)
            else:
                # GPIO.output(self.pinControl, GPIO.HIGH)
                self.pwm.start(abs(self.value)) # self.pwm.ChangeDutyCycle(abs(self.value))
                if self.value<0:
                    GPIO.output(self.pinForward, GPIO.HIGH)
                    GPIO.output(self.pinBackward, GPIO.LOW)
                else:
                    GPIO.output(self.pinForward, GPIO.LOW)
                    GPIO.output(self.pinBackward, GPIO.HIGH)

    def set(self, value):
        if self.is_writable:
            self.value = value
            if self.value < self.value_min:
                self.value = self.value_min
            if self.value > self.value_max:
                self.value = self.value_max
            self.updatePins()

    def get(self):
        return self.value

    def describe(self):
        resp = "read"
        resp += ",write " if self.is_writable else " "
        resp += self.value_type + " "
        resp += str(self.value_min) + " " + str(self.value_max)
        return resp

class HardwareHandler():
    """HardwareHandler"""
    def __init__(self):
        self.hardware = {}
        self.hardware_type_count = {}

        # Set I/O pins reference mode
        GPIO.setmode(GPIO.BOARD)

    def add(self, hardware_type, args={}):
        id_ = len(self.hardware)
        if hardware_type not in self.hardware_type_count:
            self.hardware_type_count[hardware_type] = -1
        self.hardware_type_count[hardware_type] += 1
        name = str(hardware_type) + '-' + str(self.hardware_type_count[hardware_type])

        # Default values
        is_writable = False
        value_type = "continuous"
        value_min = 0
        value_max = 1
        value = 0
        # Values more specific to hardware
        if hardware_type=="motor":
            is_writable = True
            value_type = "continuous"
            value_min = -100
            value_max = 100
            value = 0
        elif hardware_type=="servo":
            is_writable = True
            value_type = "continuous"
            value_min = -0
            value_max = 10
            value = 5
        elif hardware_type=="led":
            is_writable = True
            value_type = "binary"
            value_min = 0
            value_max = 1
            value = 0
        elif hardware_type=="infrared":
            is_writable = False
            value_type = "discrete"
            value_min = 0
            value_max = 255
            value = 0
        elif hardware_type=="battery":
            is_writable = False
            value_type = "continuous"
            value_min = 0.0
            value_max = 100.0
            value = 100.0

        # Create and add entry
        hardware = Hardware(name, hardware_type, is_writable=is_writable, value_type=value_type, \
            value_min=value_min, value_max=value_max, value=value, args=args)
        self.hardware[name] = hardware
        return id_

    def get(self, name):
        if name in self.hardware:
            return self.hardware[name].get()
        else:
            return None

    def describe(self, name):
        if name in self.hardware:
            return self.hardware[name].describe()
        else:
            return None

    def set(self, name, value):
        if name in self.hardware:
            self.hardware[name].set(value)

    def list(self):
        return self.hardware.keys()

    def cleanup(self):
        GPIO.cleanup()
