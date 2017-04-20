#! /bin/bash

# Using the instructions at
# https://www.digitalocean.com/community/tutorials/how-to-run-openvpn-in-a-docker-container-on-ubuntu-14-04?utm_source=githubreadme

OVPN_DATA="ovpn-data"

# My digital ocean droplet doesn't have an entry in DNS.
#ovpn_host="104.236.213.121"
ovpn_host="ovpn.pigsn.space"

cat <<EOF
Create an empty Docker volume container using busybox as a minimal
Docker image:

```bash
docker run --name $OVPN_DATA -v /etc/openvpn busybox
```
EOF

docker run --name $OVPN_DATA -v /etc/openvpn busybox

cat <<EOF
Initialize the $OVPN_DATA container that will hold the configuration
files and certificates, and replace vpn.example.com with your FQDN.
The vpn.example.com value should be the fully-qualified domain name
you use to communicate with the server. This assumes the DNS settings
are already configured. Alternatively, it's possible to use just the
IP address of the server, but this is not recommended.

```bash
docker run --volumes-from $OVPN_DATA --rm \
    kylemanna/openvpn ovpn_genconfig \
    -u udp://${ovpn_host}:1194
```
EOF

docker run --volumes-from $OVPN_DATA --rm \
    kylemanna/openvpn ovpn_genconfig \
    -u udp://${ovpn_host}:1194

cat <<EOF
Generate the EasyRSA PKI certificate authority. You will be prompted for
a passphrase for the CA private key. Pick a good one and remember it;
without the passphrase it will be impossible to issue and sign client
certificates:

```bash
docker run --volumes-from $OVPN_DATA --rm -it kylemanna/openvpn ovpn_initpki
```
EOF

docker run --volumes-from $OVPN_DATA --rm -it kylemanna/openvpn ovpn_initpki

cat <<EOF
# Step 3 — Launch the OpenVPN Server

To autostart the Docker container that runs the OpenVPN server process
(see Docker Host Integration for more) create an Upstart init file.

cat > /etc/init/docker-openvpn.conf <<EOF
description "Docker container for OpenVPN server"
start on filesystem and started docker
stop on runlevel [!2345]
respawn
script
  exec docker run --volumes-from ovpn-data --rm -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
end
EOF

cat > /etc/init/docker-openvpn.conf <<EOF
description "Docker container for OpenVPN server"
start on filesystem and started docker
stop on runlevel [!2345]
respawn
script
  exec docker run --volumes-from ovpn-data --rm -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
end
EOF

cat <<EOF
Start the process using the Upstart init mechanism (Ubuntu <= 14.04):"

```bash
start docker-openvpn
```
EOF

start docker-openvpn

cat <<EOF
Verify that the container started and didn't immediately crash by
looking at the STATUS column:"

```bash
docker ps
```
EOF

docker ps

cat <<EOF
# Generate Client Certificates and Config Files

In this section we'll create a client certificate using the PKI CA we
created in the last step.

Be sure to replace CLIENTNAME as appropriate (this doesn't have to be a
FQDN). The client name is used to identify the machine the OpenVPN
client is running on (e.g., "home-laptop", "work-laptop", "nexus5",
etc.).

The easyrsa tool will prompt for the CA password. This is the password
we set above during the ovpn_initpki command. Create the client
certificate:

```bash
clientname="home-router"
docker run --volumes-from $OVPN_DATA --rm -it \
    kylemanna/openvpn easyrsa build-client-full ${clientname} nopass
```
EOF

clientname="home-router"
docker run --volumes-from $OVPN_DATA --rm -it \
    kylemanna/openvpn easyrsa build-client-full ${clientname} nopass

cat <<EOF
After each client is created, the server is ready to accept connections.

The clients need the certificates and a configuration file to connect.
The embedded scripts automate this task and enable the user to write out
a configuration to a single file that can then be transfered to the
client. Again, replace CLIENTNAME as appropriate:

```bash
docker run --volumes-from $OVPN_DATA --rm kylemanna/openvpn \
    ovpn_getclient ${clientname} > ${clientname}.ovpn
```
EOF

docker run --volumes-from $OVPN_DATA --rm kylemanna/openvpn \
    ovpn_getclient ${clientname} > ${clientname}.ovpn

cat <<EOF
The resulting CLIENTNAME.ovpn file contains the private keys and
certificates necessary to connect to the VPN. Keep these files secure
and not lying around. You'll need to securely transport the *.ovpn files
to the clients that will use them. Avoid using public services like
email or cloud storage if possible when transferring the files due to
security concerns.

Recommend methods of transfer are ssh/scp, HTTPS, USB, and microSD cards
where available.
EOF

cat <<EOF
# Step 5 — Set Up OpenVPN Clients

The following are commands or operations run on the clients that will
connect to the OpenVPN server configured above.

## Ubuntu and Debian Distributions via Native OpenVPN On Ubuntu 12.04/14.04
## and Debian wheezy/jessie clients (and similar):

Install OpenVPN:
```bash
sudo apt-get install openvpn
```
Copy the client configuration file from the
server and set secure permissions:

```bash
sudo install -o root -m 400 CLIENTNAME.ovpn /etc/openvpn/CLIENTNAME.conf
```

Configure the init scripts to autostart all configurations matching
/etc/openvpn/*.conf:

```bash
echo AUTOSTART=all | sudo tee -a /etc/default/openvpn
```

Restart the OpenVPN client's server process:

```bash
sudo /etc/init.d/openvpn restart
```

## Arch Linux via Native OpenVPN Install

OpenVPN:

```bash
pacman -Sy openvpn
```

Copy the client configuration file from the server
and set secure permissions:

```bash
sudo install -o root -m 400 CLIENTNAME.ovpn /etc/openvpn/CLIENTNAME.conf
```

Start OpenVPN client's server process:

```bash
systemctl start openvpn@CLIENTNAME
```

Optional: configure systemd to start
/etc/openvpn/CLIENTNAME.conf at boot:

```bash
systemctl enable openvpn@CLIENTNAME
```

## MacOS X via TunnelBlick

Download and install TunnelBlick.

Copy CLIENTNAME.ovpn from the server to the Mac.

Import the configuration by double clicking the *.ovpn file copied
earlier. TunnelBlick will be invoked and the import the configuration.

Open TunnelBlick, select the configuration, and then select connect.

## Android via OpenVPN Connect

Install the OpenVPN Connect App from the
Google Play store.

Copy CLIENTNAME.ovpn from the server to the Android device in a secure
manner. USB or microSD cards are safer. Place the file on your SD card
to aid in opening it.

Import the configuration: Menu -> Import -> Import Profile from SD card

Select connect.

# Step 6 — Verify Operation

There are a few ways to verify that traffic is being routed through the
VPN.

## Web Browser
Visit a website to determine the external IP address. The external IP
address should be that of the OpenVPN server.

Try Google "what is my ip" or icanhazip.com.

## Command Line
From the command line, wget or curl come in handy. Example with curl:

curl icanhazip.com

Example with wget:

wget -qO - icanhazip.com

The expected response should be the IP address of the OpenVPN server.

Another option is to do a special DNS lookup to a specially configured
DNS server just for this purpose using host or dig. Example using host:

host -t A myip.opendns.com resolver1.opendns.com

Example with dig:

dig +short myip.opendns.com @resolver1.opendns.com

The expected response should be the IP address of the OpenVPN server.

## Extra Things to Check
Review your network interface configuration. On Unix-based operating
systems, this is as simple as running ifconfig in a terminal, and
looking for OpenVPN's tunX interface when it's connected.

Review logs. On Unix systems check /var/log on old distributions or
journalctl on systemd distributions.

# Conclusion

The Docker image built to run this is open source and capable of much
more than described here.

The [docker-openvpn source repository][https://github.com/kylemanna/docker-openvpn]
is available for review of the code as well as forking for
modifications. Pull requests for general features or bug fixes are
welcome.

Advanced topics such as backup and static client IPs are discussed under
the [docker-openvpn/docs][https://github.com/kylemanna/docker-openvpn/tree/master/docs]
folder.

Report bugs to the [docker-openvpn issue tracker][https://github.com/kylemanna/docker-openvpn/issues].

EOF


