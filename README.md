# new-host-setup
Stuff to do when setting up a new (Debian/Ubuntu) host

- Just document tasks first, then script those tasks
- On locally controlled hosts
  - Create a / root partition formatted with btrfs that is spread across two devices and is only 20GiB in size
  - Leave root unencrypted so bootup can complete
  - Create a small partition for swap and mount using encryption
  - Create additional large partitions on the rest of the devices
  - Use LUKS to encrypt the rest of the devices
- On remote hosts (e.g. Digital Ocean droplets)
  - Create swap file and mount using dm-crypt
  - Create big file and encrypt with LUKS (leave 5-8GiB free for root)
    - Refer to [this post about how to create an encrypted loop device][1]
- On both local and remote hosts
  - format big devices with btrfs (for local, use mirroring for data)
  - Create subvolumes in btrfs filesystem to mount to /home and selected directories in /var
  - A script on boot will check for the presence of a key file (in configurable location, but typically a usb thumb drive) and use it to open the encrypted devices
  - add a user that will only be used to login and decrypt disks after bootup (only needed if usbdrive with key to unlock disks is not present)
    - this user's home directory will be something like /var/home/username
  - don't start any services that are run in docker containers until the encrypted devices are mounted
    - will have to check for those mounts on startup somehow
    - 

- Security
  - adduser --gecos "" jwheaton
  - adduser jwheaton sudo
  - [Secure with 2-factor auth using Google Authenticator][2]
  - Update /etc/ssh/sshd_conf
    - Disallow root login
    - For any additional users created, only allow RSA authentication; no password authentication
      - Maybe by updating default scripts for user creation?
- Add docker repository for Debian to /etc/apt/sources
- Import docker keys
- apt-get udpate
- apt-get install docker-machine
- Install docker compose:

          curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose

- apt-get install tmux
- Use docker images for custom-crafted services that we want to be able to run anywhere

[1]: https://www.digitalocean.com/community/tutorials/how-to-use-dm-crypt-to-create-an-encrypted-volume-on-an-ubuntu-vps
[2]: http://www.howtogeek.com/121650/how-to-secure-ssh-with-google-authenticators-two-factor-authentication/
