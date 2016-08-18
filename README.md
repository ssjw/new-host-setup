# new-host-setup
Stuff to do when setting up a new (Debian/Ubuntu) host

- Just get tasks down first, then script those tasks
- Install to encrypted root?
  - Ugh... all the pain
  - How feasible on remote host?  Probably not very
  - Remote host... just encrypt /home and select parts of /var?
    - How to do that and not have to create a bunch of partitions that cause space to lost that will never be used?
    - Requires more thought...
    - Want something that could be done to every host in a consistent manner, whether remote or local, without the possibility of making a remote host inaccessible
- Security
  - Create a non-root user
  - Secure with 2-factor auth using Google Authenticator
  - Update /etc/ssh/sshd_conf
    - Disallow root login
    - For any additional users created, only allow RSA authentication; no password authentication
      - Maybe by updating default scripts for user creation?
- Add docker repository for Debian to /etc/apt/sources
- Import docker keys
- apt-get udpate
- apt-get install docker-machine?
- Use docker images for custom-crafted services that we want to be able to run anywhere
