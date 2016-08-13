#!/usr/bin/env python
# -*- coding: utf-8 -*-

from hardware import HardwareHandler
import json
import threading

class Controller():
    """Controller"""
    def __init__(self):
        self.HardwareHandler = HardwareHandler()
        self.load("hardware.json")
        self.timer = None

    def scheduleReset(self):
        if self.timer is not None:
            self.timer.cancel()
        self.timer = threading.Timer(5, self.reset)
        self.timer.start()

    def reset(self):
        # print("Resetting...")
        for h in self.HardwareHandler.list():
            self.HardwareHandler.set(h, float(0))

    def load(self, filename):
        with open(filename) as f:
            hardware = json.load(f)
            for h in hardware:
                hardware_type = h['hardware_type']
                self.HardwareHandler.add(hardware_type, h['args'])

    def process(self, msg):
        # print('Received message: %s' % (msg))
        msg_parts = msg.split()
        resps = {}

        if len(msg_parts)<2:
            return []
        req_type = msg_parts[0]
        targets = msg_parts[1] # target hardware

        if targets == "*":
            targets = self.HardwareHandler.list()
        else:
            targets = [targets]

        if req_type == "get":
            for hardware_name in targets:
                hardware_value = self.HardwareHandler.get(hardware_name)
                if hardware_value is not None:
                    resp = {}
                    resp['name'] = hardware_name
                    resp['value'] = hardware_value
                    resps[hardware_name] = resp
        elif req_type == "describe":
            for hardware_name in targets:
                hardware_value = self.HardwareHandler.get(hardware_name)
                if hardware_value is not None:
                    resp = {}
                    resp['name'] = hardware_name
                    resp['value'] = hardware_value
                    resp['details'] = str(self.HardwareHandler.describe(hardware_name))
                    resps[hardware_name] = resp
        elif req_type == "set":
            if len(msg_parts)<3:
                return []
            try:
                new_value = float(msg_parts[2])
            except:
                return []

            for hardware_name in targets:
                self.HardwareHandler.set(hardware_name, new_value)

                hardware_value = self.HardwareHandler.get(hardware_name)
                if hardware_value is not None:
                    resp = {}
                    resp['name'] = hardware_name
                    resp['value'] = hardware_value
                    resps[hardware_name] = resp

        self.scheduleReset()
        return resps

    def cleanup(self):
        self.HardwareHandler.cleanup()
