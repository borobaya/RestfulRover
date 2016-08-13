#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import os, sys
from controller import Controller
from flask import Flask, request
from pprint import pformat
import json

app = Flask(__name__)
server = None

@app.route('/')
def index():
    return "<a href='/hardware'>Go to /hardware for hardware details.</a>"

@app.route('/hardware/')
def list_all_hardware():
    hardware = server.send_message("get *")
    return json.dumps(hardware)

@app.route('/hardware/<name>/', methods=['POST', 'GET', 'PUT'])
@app.route('/hardware/<name>/<command>/', methods=['POST', 'GET', 'PUT'])
@app.route('/hardware/<name>/<command>/<value>/', methods=['POST', 'GET', 'PUT'])
def hardware(name=None, command=None, value=None):
    # Use GET and POST as data sources
    if command is None and "command" in request.args:
        command = str(request.args['command'])
    if value is None and "value" in request.args:
        value = str(request.args['value'])
    if command is None and "command" in request.form:
        command = str(request.form['command'])
    if value is None and "value" in request.form:
        value = str(request.form['value'])
    if command is None:
        if value is None:
            command = "get"
        else:
            command = "set"
    if value is None:
        value = ""

    # Formulate request string
    request_string = None
    if name==None or command==None or value==None:
        return "ERROR"

    request_string = str(command) + " " + str(name) + " " + str(value)
    request_string = request_string.strip()

    # Formulate response
    hardware = server.send_message(request_string)
    return json.dumps(hardware)

class Server():
    """Server"""
    def __init__(self):
        self.controller = Controller()
        print("Hardware initialisation completed")
    
    def send_message(self, msg):
        return self.controller.process(msg)
    
    def cleanup(self):
        self.controller.cleanup()

def main():
    """main function"""
    global app, server
    
    # Sanity check
    if os.geteuid() != 0:
        print("Warning: Need administrator privileges to access onboard pins! Use 'sudo'.")
        return
    
    try:
        # Initialise
        server = Server()
    
        print("Starting server...")
        context = ('ssl.crt', 'ssl.key')
        app.run(debug=True, host='0.0.0.0', port=443, use_reloader=False, ssl_context=context)
    finally:
        print("\Exiting..")
        server.cleanup()
        sys.exit(0)

if __name__ == "__main__":
    main()
