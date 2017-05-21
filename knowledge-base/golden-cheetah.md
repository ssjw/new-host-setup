# GoldenCheetah Setup (on Ubuntu 17.04)

Using package in repo (apt install goldencheetah) the following needed
to be done.

'''shell
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0fcf", ATTRS{idProduct}=="1009", MODE="0666"' >> /etc/udev/rules.d/51-garmin-usb.rules
adduser jwheaton dialout
'''

Then logout and log back into pickup the new group.

