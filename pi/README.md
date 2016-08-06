
# Rover RESTful Controller

Developed on Python 3, made for the Raspberry Pi

## Installation Instructions

### Generic Raspberry Pi installation stuff

```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y git python-pip python-all-dev
```

To set up SSH, check
https://www.raspberrypi.org/documentation/remote-access/ssh/

### Python Webserver

```bash
sudo apt-get install python3-flask
sudo apt-get install python-rpi.gpio python3-rpi.gpio
```

### SSL certificate

```bash
sudo apt-get -y install python3-pip
sudo pip3 install Werkzeug --upgrade
```

Go inside the pi directory, then:
```
openssl req \
       -newkey rsa:2048 -nodes -keyout ssl.key \
       -x509 -days 365 -out ssl.crt
```
Note: This is a self-signed certificate

## Usage

Run the following command in this directory to start the RESTful API
to control the Rover:

```
sudo python3 start.py
```

## URLs

At the IP address of the Raspberry Pi, the following URLs
are exposed (using https):

- /hardware - View list of all hardware
- /hardware/abcd - View hardware 'abcd'
- /hardware/abcd/set/3 - Set hardware 'abcd' value to 3



