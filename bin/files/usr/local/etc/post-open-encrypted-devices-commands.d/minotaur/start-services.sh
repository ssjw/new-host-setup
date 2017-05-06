# Start the services that depend encrypted devices.

systemctl start subsonic
systemctl status --no-pager subsonic

systemctl start burp
systemctl status --no-pager burp

# vim:tw=76:sts=4:sw=4
