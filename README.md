# new-host-setup
Stuff to do when setting up a new (Debian/Ubuntu) host

- Just get tasks down first, then script those tasks
- Install to encrypted root?
  - dm-crypt disks for local hosts
  - Remote host... just encrypt /home and select parts of /var?
    - Refer to [this post about how to create an encrypted loop device][1]
    - mount sub-dirs of the encrypted loop device onto directories of /?
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
- Install docker compose:

      curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose

- apt-get udpate
- apt-get install docker-machine docker-compose
- apt-get install tmux
- Use docker images for custom-crafted services that we want to be able to run anywhere

[1]: https://www.digitalocean.com/community/tutorials/how-to-use-dm-crypt-to-create-an-encrypted-volume-on-an-ubuntu-vps
[2]: http://www.howtogeek.com/121650/how-to-secure-ssh-with-google-authenticators-two-factor-authentication/
