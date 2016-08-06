
# Rover RESTful Controller

Raspberry Pi

Developed on Python 3

## Installation Instructions

sudo apt-get install python3-flask
sudo apt-get install python-rpi.gpio python3-rpi.gpio

To get SSL certificate working:
sudo apt-get -y install python3-pip
sudo pip3 install Werkzeug --upgrade


Go inside the pi directory, then:
openssl req \
       -newkey rsa:2048 -nodes -keyout ssl.key \
       -x509 -days 365 -out ssl.crt
Note: This is a self-signed certificate

## URLs

/hardware - View list of all hardware

/hardware/abcd - View hardware 'abcd'

/hardware/abcd/set/3 - Sets hardware 'abcd' value to 3



