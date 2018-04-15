# Start the services that depend encrypted devices.

systemctl start mariadb
systemctl status --no-pager mariadb

systemctl start apache2
systemctl status --no-pager apache2

# vim:tw=76:sts=4:sw=4
