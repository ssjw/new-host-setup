# new-host-setup
Stuff to do when setting up a new (Debian/Ubuntu) host

- Just document tasks first, then script those tasks
- On locally controlled hosts
  - [ ] Create a / root partition formatted with btrfs that is spread across two
    devices and is only 20GiB in size
  - [ ] Leave root unencrypted so bootup can complete
  - [ ] Create a small partition for swap and mount using encryption
  - [ ] Create additional large partitions on the rest of the devices
  - [ ] Use LUKS to encrypt the rest of the devices
- On remote hosts (e.g. Digital Ocean droplets)
  - [ ] Create swap file and mount using dm-crypt
  - [ ] Create big file and encrypt with LUKS (leave 10GiB free for root)
    - [ ] Refer to [this post about how to create an encrypted loop device][1]
- On both local and remote hosts
  - [ ] format big devices with btrfs (for local, use mirroring for data)
  - [ ] Create subvolumes in btrfs filesystem to mount to /home and selected
    directories in /var
  - [ ] add a user that will only be used to login and decrypt disks after
    bootup (only needed if usbdrive with key to unlock disks is not present)
    - [ ] this user's home directory will be something like /home2/unlocker
  - [ ] don't start any services that are run in docker containers until the
    encrypted devices are mounted
    - [x] will have to check for those mounts on startup somehow

## Security
- [x] adduser --gecos "" jwheaton
- [x] adduser jwheaton sudo
- [x] adduser --home /home2/unlocker --gecos "" unlocker
- [ ] [Secure with 2-factor auth using Google Authenticator][2]
  - [x] Install libpam-google-authenticator
  - [x] Generate .google_authenticator files for users jwheaton & unlocker
  - [ ] generate and send pgp-encrypted email with codes to
    jhwheaton@gmail.com
  - [ ] Update /etc/ssh/sshd_conf
    - [ ] Make sure PermitRootLogin is set to "without-password"
    - [ ] For any additional users created (other than user "unlocker"),
      only allow RSA authentication; no password authentication (then why
      setup google_authentication for them?)
    - [x] Setup /etc/ssh/sshd_conf for Google authentication

## Other
### Docker
- [x] Add docker repository for Debian to /etc/apt/sources
  - [x] apt-get install apt-transport-https ca-certificates
  - [x] apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  - [x] echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list
  - [x] apt-get update
  - [x] apt-get install docker-engine
  - [x] service docker start

### Docker Compose
- [ ] install docker compose

        curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose

### Miscelaneous
- [ ] apt-get install tmux git dialog sshd (will need to run manually)
- [ ] Setup SSH server
- [ ] Setup static IP
- [ ] git clone https://github.com/ssjw/new-host-setup.git
- [x] script to add additional packages to OS.
- [x] script to copy stuff to /usr/local/bin (mylsblk)
- [ ] script to setup Vim environment (plug-ins, .vimrc, etc.)
- [ ] script to run cryptsetup

## Docker Usage Notes
- Use docker images for custom-crafted services that we want to be able to run anywhere
- Dockerized services should be started after all encrypted devices have been mounted
  - How does this get triggered?
  - Perhaps there is a service started at boot that's checking to see if all
    encrypted devices have been mounted, and then starts all of the services
    that depend on them
    - Configuration
      - encrypted devices and their mount points (crypttab and/or fstab)
      - Docker services to be started (maybe this is just a yml file for docker-compose)

[1]: https://www.digitalocean.com/community/tutorials/how-to-use-dm-crypt-to-create-an-encrypted-volume-on-an-ubuntu-vps
[2]: http://www.howtogeek.com/121650/how-to-secure-ssh-with-google-authenticators-two-factor-authentication/

vim:ts=2:sw=2:sts=2:tw=76
