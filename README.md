# RestfulRover

Quick notes on how to get the code to work (more for me at this early stage
of development).

## Rasberry Pi

```shell
git clone https://github.com/momiah/RestfulRover.git
```

See the README.md file in the pi folder.

To find the local IP address, use `sudo ifconfig wlan0`

To find the external IP address, you can use `curl icanhazip.com`

Note that to be able to control the rover from anywhere in the world, you
will need to expose port 443 (https) to the external internet. This usually
means updating the firewall settings on your router.

## Using the Camera on the Raspberry Pi

First, enable the camera through

```shell
sudo raspi-config
```

Install the uv4l camera driver:

```shell
wget http://www.linux-projects.org/listing/uv4l_repo/lrkey.asc && sudo apt-key add ./lrkey.asc  
echo "deb http://www.linux-projects.org/listing/uv4l_repo/raspbian/ wheezy main" | sudo tee -a /etc/apt/sources.list  
sudo apt-get update  
sudo apt-get install -y uv4l uv4l-raspicam uv4l-raspicam-extras uv4l-server uv4l-uvc uv4l-xscreen uv4l-mjpegstream  
sudo reboot
```

The UV4L Streaming Server is now exposed on port 8080.

For more information on setting up the Raspberry Pi Camera, check out
http://www.home-automation-community.com/surveillance-with-raspberry-pi-noir-camera-howto/

Tip: In case the camera fails to turn off after disconnecting from it, restart the
uv4l-server on the Raspberry Pi using:

```shell
sudo service uv4l_raspicam restart
```


