# Configuring Host backuppi

- [Todo](#todo)
- [Firewall configuration for SSH](#firewall-configuration-for-ssh)
- [Enabling SSH-server on Debian](#enabling-ssh-server-on-debian)
- [Configuring a Static IP for the
    Interface](#configuring-a-static-ip-for-the-interface)
- [Changing Systemd Boot Target Systemd OSes](#changing-systemd-boot-target-on-systemd-oses)
- [Configuring gocryptfs for Encrypted Home
    Directories](#configuring-gocryptfs-for-encrypted-home-directories)
- [SSMTP Configuration](#ssmtp-configuration)
- [Google Two-Factor Authentication](#google-two-factor-authentication)
- [Adduser](#adduser)
- [Disable Passwordless sudo](#disable-passwordless-sudo)
- [Install BURP](#install-burp)
- [Add ufw Firewall Rule for BURP](#add-ufw-firewall-rule-for-burp)
- [Router Port Forwarding](#router-port-forwarding)
- [Configuring BURP to Start on Boot](#configuring-burp-to-start-on-boot)
- [Setting Up Disk Encryption](#setting-up-disk-encryption)
- [Root on an Encrypted Multi-Device
  Filesystem](#root-on-an-encrypted-multi-device-filesystem)
- [Swap files Don't Work on BTRFS](#swap-files-dont-work-on-btrfs)
- [How to SSH into the Pi to Unlock the Encrypted
  Disks](#how-to-ssh-into-the-pi-to-unlock-the-encrypted-disks)
- [Using a Keyfile to Open the Encrypted Disks During
  Boot](#using-a-keyfile-to-open-the-encrypted-disks-during-boot)
- [Opening Encrypted Disks After Boot](#opening-encrypted-disks-after-boot)
- [Configuring Windows Clients to Backup to Two Backup
  Servers](#configuring-windows-clients-to-backup-to-two-backup-servers)

## Todo
- [ ] setup SSH server
- [ ] update ufw for SSH
- [ ] add user jwheaton and setup two-factor auth
- [ ] disable passwordless sudo
- [ ] configure SSMTP
- [ ] keyscript to open encrypted disks

## Firewall configuration for SSH
Install UFW (firewall)

    apt-get install ufw

List the available apps:

    ufw app list

Allow OpenSSH

    ufw app info OpenSSH
    ufw allow OpenSSH

Then enable ufw.  Must be done in this order or you risk losing your SSH
connection and not being able to log back in using SSH.  If that happens
you'll have to log into the console to then allow OpenSSH.

    ufw enable

## Enabling SSH-server on Debian
Issue the commands:

    systemctl enable ssh
    systemctl start ssh

## Configuring a Static IP for the Interface
`dhcpcd` is the dhcp client configured by default on Raspbian to control
network interfaces.  It's configuration needs to be changed to switch the
eth0 interface (or wifi interface if using wifi) to be a static address
instead of one leased from the dhcp server.

Edit /etc/dhcpcd.  Find the example static IP configuration section and
update to something like the following example, which sets ipv4 address to
192.168.1.101, disables ipv6 addresses, sets static routers, and sets name
servers to Google's name servers:

    # Example static IP configuration:
    interface eth0
    static ip_address=192.168.1.101/24
    #static ip6_address=fd51:42f8:caae:d92e::ff/64
    noipv6rs
    static routers=192.168.1.1
    static domain_name_servers=8.8.8.8 8.8.4.4

## Changing Systemd Boot Target on Systemd OSes
A seemingly good explanation of Systemd is at
[https://wiki.archlinux.org/index.php/systemd].

Change the default boot target to the multi-user target instead of the
graphical target (this Raspberry Pi will generally be run headless).

    systemctl set-default multi-user.target

To change immediately to the multi-user target issue this command:

    systemctl isolate multi-user.target

Similarly to change back to the graphical target:

    systemctl isolate graphical.target

## Configuring gocryptfs for Encrypted Home Directories
NOTE: Deprecated. Just use ecryptfs instead.  It uses a kernel module and is
integrated into Debian/Ubuntu.

### Installation

    apt-get install gocryptfs libpam-mount
 
### Create a gocryptfs Filesystem:

    mkdir /home/jwheaton.cipher /home/jwheaton
    gocryptfs -init /home/jwheaton.cipher

When asked for the password, make sure to make it the same as the user's
login password, or mounting the volume will fail during login.  It likely
could be mounted manually afterward.

### Configuration

`/etc/security/pam_mount.conf.xml` and `/etc/pam.d/sshd` are mostly
configured correctly already. We just need to confugure each user's home
volume in `/etc/security/pam_mount.conf.xml`.

We need to update `/etc/fuse.conf` and make sure the option
`user_allow_other` exists and is not commented out.  This option will allow
other users (namely root) to read the mounted directory.  Without this
option only the user that mounts the volume will be able to read it.

### Add volume configuration to pam_mount.conf.xml

    <volume user="jwheaton" fstype="fuse" options="nodev,nosuid,quiet,nonempty,allow_other"
            path="/usr/bin/gocryptfs#/home/%(USER).cipher" mountpoint="/home/%(USER)" />

It's possible the user attribute could be set to "%(USER)" as well so that
all users would have encrypted home directories, but that would be dangerous
as _not_ all users have encrypted home directories.

## SSMTP Configuration
### ssmtp.conf
    apt-get install ssmtp
    vi /etc/ssmtp/ssmtp.conf

	#  
	# Config file for sSMTP sendmail  
	#  
	# The person who gets all mail for userids &lt; 1000  
	# Make this empty to disable rewriting.  
	#root=postmaster  
	root=jonathan@ourplaceontheweb.org  
  
	# The place where the mail goes. The actual machine name is required
	no  
	# MX records are consulted. Commonly mailhosts are named
	mail.domain.com  
	mailhub=smtp.gmail.com:587  
  
	# Where will the mail seem to come from?  
	#rewriteDomain=  
	  
	# The full hostname  
	hostname=backuppi@ourplaceontheweb.org  
	  
	UseSTARTTLS=YES  
	AuthUser=jhwheaton  
	AuthPass=[app password from Google.com for my account]  
	  
	# Are users allowed to set their own From: address?  
	# YES - Allow the user to specify their own From: address  
	# NO - Use the system generated From: address  
	FromLineOverride=YES

### revaliases

	vi /etc/ssmtp/revaliases

	# sSMTP aliases  
	#  
	# Format:       local_account:outgoing_address:mailhub  
	#  
	# Example: root:your_login@your.domain:mailhub.your.domain[:port]  
	# where [:port] is an optional port number that defaults to 25.  
	root:root@backuppi.ourplaceontheweb.org:smtp.gmail.com:587  
	jwheaton:jwheaton@backuppi.ourplaceontheweb.org:smtp.gmail.com:587

## Google Two-Factor Authentication

	apt-get install libpam-google-authenticator

### Create an Authentication Key

Log in as the user you’ll be logging in with remotely and run the
google-authenticator command to create a secret key for that user.
 Example:

	ssh jwheaton@192.168.1.105

	jwheaton@backuppi ~ $ google-authenticator

	Picture of a QR code in ASCII art. Nice!
	
	Your new secret key is: UHEKTYEKDNBKISYH
	Your verification code is 887698
	Your emergency scratch codes are:
	  xxxxxxxx
	  xxxxxxxx
	  xxxxxxxx
	  xxxxxxxx
	  xxxxxxxx

Scan the QR code with the Google Authenticator app on your phone.
 Here's how I answered the questions from the google-authenticator
command:

	Do you want me to update your "~/.google_authenticator" file (y/n) y
	
	Do you want to disallow multiple uses of the same authentication token? This restricts you to one login about every 30s, but it increases your chances to notice or even prevent man-in-the-middle attacks (y/n) y
	
	By default, tokens are good for 30 seconds and in order to compensate for possible time-skew between the client and the server, we allow an extra token before and after the current time. If you experience problems with poor time synchronization, you can increase the window from its default size of 1:30min to about 4min. Do you want to do so (y/n) n
	
	If the computer that you are logging into isn't hardened against
	brute-force login attempts, you can enable rate-limiting for the authentication module.
	
	By default, this limits attackers to no more than 3 login attempts every 30s.
	
	Do you want to enable rate-limiting (y/n) y
	
	Write down the emergency scratch codes!  Put them in your wallet.

The rest of this is done as root.

	vi /etc/pam.d/sshd

Add the following two lines.

	# Require Google two-factor authentication
	auth required pam_google_authenticator.so

Open sshd_config, find the string ChallengeResponseAuthentication, and
change it to 'yes'

	vi /etc/ssh/sshd_config

Then restart the ssh service.

	service ssh restart

## Adduser

	adduser jwheaton --gecos ""

## Disable Passwordless sudo

The default installation of Raspbian on Raspberry Pi adds users to the
sudoers file as being able to run all commands without entering a
password.  This is a security risk, so:

	visudo

find the line for the the user `(jwheaton)`, and remove the `"NOPASSWD:"` in
front of the last `"ALL"`.

## Install BURP

Consult the BURP install document.

## Add ufw Firewall Rule for BURP

    vi /etc/ufw/applications.d/burp

    [burp]
    title=BURP (Backup and Recovery Program)
    description=BURP (Backup and Recovery Program)
    ports=4971:4972/tcp

    :wq

    ufw allow burp

## Router Port Forwarding

Don't forget to port forward the two ports 4971 and 4972 on the WAN
router (when this is host will be backing up remote hosts only)

## Configuring BURP to Start on Boot

Edit `/etc/default/burp` after installing burp via apt-get.

## Sensible Encryption Setup
A sensible setup for encryption that I've settled on is the following:

- A separate partition for encrypted swap
- An unencrypted filesystem for root (so that we can boot the system and ssh
    into it to decrypt everything needed to run services and allow normal
    users to log in)
- An encrypted btrfs filesystem with subvolumes for mounting at /home,
    /var/www/, /var/nextcloud/data, /var/mysql, etc.
- A user (unlocker) with home as /unlocker so that it is accessable on boot

### Normal operation
1. Allow the system to boot
2. Log in as unlocker and open the encrypted partition(s)
3. mount the encrypted partitions
4. start the services that depend on the encrypted partition

The last two steps can be combined into a script.  Some of this is in the
ssjw/new-host-setup repo on Github.

## Setting Up Disk Encryption

### Write Random Noise to Disk to Mask Filesystem

This is done to overwrite whatever sensitive data might have already
been on the drive.  If you've never used the drive, this step is
probably not needed.  It takes several hours to complete.

Use the following command to write random noise to the entire disk or
partition.  Note: this finished with an error about writing to file, but
I think that is probably because the pipe closed when it got to the end
of the disk.

    openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/urandom bs=128 count=1 > /dev/null | base64)" -nosalt < /dev/zero > /dev/sdc

### Encrypt the Disks

Load some kernel modules that we'll need.  I'm not sure the manual load
is needed… the web page I was working from had this command.

    modprobe dm-crypt sha256 aes

Create the encrypted volume:

    cryptsetup --verify-passphrase luksFormat /dev/sdc --cipher aes-xts-plain64 --key-size 512 --hash sha256

    cryptsetup --verify-passphrase luksFormat /dev/sdd --cipher aes-xts-plain64 --key-size 512 --hash sha256

Save password in LastPass

TODO: create hard copy and put in safe.

### Open the Encrypted Volumes

Now we need to open the encrypted volumes:

    cryptsetup luksOpen /dev/sdb enc1

    cryptsetup luksOpen /dev/sdc enc2

The `cryptsetup` command takes a password and decrypts the volumes as block
devices in /dev (dm-0, dm-1, …) and creates links to them in /dev/mapper
with the names given (/dev/mapper/enc1, /dev/mapper/enc2, ...)

### Create Filesystem on Encrypted Volumes

    mkfs.btrfs -L btrfs01 -m raid1 -d raid0 /dev/mapper/enc1 \
    /dev/mapper/enc2

### Setup Encrypted Volumes to Open on Boot

Edit /etc/crypttab

    # <target name> <source device> <key file> <options>
    # Wait for 24 hours for someone to enter a password
    enc1 /dev/disk/by-uuid/8515c30a-9227-41a0-9b85-98dba70af9dc none luks,timeout=86400
    enc2 /dev/disk/by-uuid/489e4f61-e8f8-4d95-9fbe-afe75414bc3f none luks,timeout=86400

Specifying "none" for the &lt;key file> parameter means to get the
password from the terminal.

With systemd (default for Ubuntu 15.10, and Debian Jessie), the second
volume is opened automatically for you after typing in the password at the
terminal to open the first encrypted volume.

### Setup Filesystem to Mount on Boot

Edit /etc/fstab (this one is from host minotaur)

    # device; this may be used with UUID= as a more robust way to name
    devices
    # that works even if disks are added and removed. See fstab(5).
    #
    # <file system> <mount point>   <type>     <options>       <dump>  <pass>
    #
    # root
    #
    UUID=f55c2f1a-a517-40ae-a169-9bc582ce84ec / ext4 errors=remount-ro 0 1
    #
    # swap
    #
    UUID=58803205-9660-4062-9168-dced3ca81bb4 none swap sw 0 0
    #
    # backups, volume label is backups-01
    #
    #UUID=cf4b85bb-bf8a-48cc-8382-25498f31faea /var/spool/burp ext4 errors=remount-ro 0 1
    #
    # Media filesystem 1.4T, volume label is backups-02, but needs to be changed
    #
    UUID=6fe0b91b-b4d8-4698-82f7-c480da0efd60 /mnt/media ext4 errors=remount-ro 0 1
    #
    # minotaur-all
    #
    /dev/disk/by-uuid/87235b43-74ac-4902-8679-ff4e82111d21 /var/spool/burp btrfs subvol=backup-01,noatime,compress=lzo 0 1

The last entry is the UUID for the filesystem on the encrypted volume,
gathered by running "lsblk -f".  For btrfs, use mount options
"noatime,compress=lzo".  Use Google search if you want to know why.

Run this command after updating /etc/fstab:

    systemctl daemon-reload

### Updating /etc/fstab in a systemd System

\[systemd-fstab-generator\] is "...a program that reads /etc/fstab at
boot time and generates units that translate fstab records to the
systemd way of doing things\[.....\]

The systemd way of doing things is mount and device units, per the
systemd.mount(5) and systemd.device(5) manual pages. In the raw systemd
way of doing things, there's a device unit named "dev-sde1.device" which
is a base requirement for a mount unit named "mnt-zeno.mount".[1]

After altering fstab one should either run `systemctl daemon-reload` (this
makes systemd to reparse /etc/fstab and pick up the changes) or reboot.

### Update initramfs

    update-initramfs -u `uname -r`

## Root on an Encrypted Multi-Device Filesystem

Like a btrfs filesystem on top of multiple encrypted hard disks.

Some reference:

[https://www.freedesktop.org/software/systemd/man/systemd-cryptsetup-generator.html]

Especially read `/usr/share/doc/cryptsetup/README.initramfs`.

cd Mount the new root filesystem to something like `/mnt/root`.

    mount -type btrfs -o subvol=root,noatime,compress=lzo \
    /dev/disk/by-uuid/87235b43-74ac-4902-8679-ff4e82111d21 /mnt/root

Copy the current root to the new root.

    cd /root
    cp -a --one-filesystem

Make the additional necessary directories in the root.

Bind some existing mounts that will be needed for the following steps.

cd into the new root.

Edit fstab to change the root directory to our new btrfs filesystem
subvolume.

Check crypttab to be sure there is an entry for each encrypted disk.
These entries tell the boot scripts in the initial ramdisk which disks
need to be opened before mounting any filesystems

## Swap files Don't Work on BTRFS

For details see:
[https://btrfs.wiki.kernel.org/index.php/FAQ\#Does\_btrfs\_support\_swap\_files.3F]

Work around is an encrypted swap partition.

Create a partition.

    # parted /dev/sde
    (parted) mkpart primary linux-swap 1MiB 512MiB
    (parted) align-check optimal 1
    optimal
    (parted) quit

Update /etc/crypttab

    swap /dev/disk/by-partuuid/xxx /dev/urandom swap,cipher=aes-xts-plain64,size=512

Update /etc/fstab

    /dev/mapper/swap none swap sw 0 0

## How to SSH into the Pi to Unlock the Encrypted Disks

I didn't spend enough time with this to get it to work, so disregard.

Much of this section copied verbatim from
[http://paxswill.com/blog/2013/11/04/encrypted-raspberry-pi/].

Having to be physically at the Pi to unlock the disk can be a pain, but
there is a way of unlocking it over SSH. The Dropbear SSH server is a
very small and lightweight server that can be run from the initramfs. It
will automatically add itself to the initramfs if it detects an
encrypted partition on the system.

    sudo apt-get install dropbear

Dropbear creates a private/public key pair when the initramfs is updated
and writes the public key to:

    Wrote key to '/etc/initramfs-tools/root/.ssh/id\_rsa'

Copy the private key to the computer you would use to ssh into the pi.

    scp /etc/initramfs-tools/root/.ssh/id\_rsa \
    aaaaa@192.168.1.xxx:~/.ssh/id\_rsa\_backuppi\_dropbear

Finally, edit initramfs’ `authorized_keys` file to have Dropbear show you
the password prompt as soon as you connect.

    vi /etc/initramfs-tools/root/.ssh/authorized\_keys  

Add this chunk of text just on a new line before the ssh-rsa at the
beginning of the file. This starts the unlock script, and once it has
exited it stops the other instance of the unlock script so boot can
continue.

    command="/scripts/local-top/cryptroot && kill -9 \`ps | grep -m 1 \
    'cryptroot' | cut -d ' ' -f 3\`"  

And finally, rebuild initramfs for the last time (until you upgrade your
kernel).

    sudo update-initramfs -u  

To test it out, restart your Pi, and then try logging in from another
computer (this step is from another computer that has network access to
the Pi).

    ssh -i ~/.ssh/id\_rsa\_backuppi\_dropbear root@192.168.1.105  

You should be asked to enter a password, and once a correct one has been
entered the Pi will boot up the rest of the way.

## Using a Keyfile to Open the Encrypted Disks During Boot

This is not a good idea, generally.  I came up with a better method that
opens the encrypted disks remotely after bootup instead.

Create an ext4 filesystem on the USB device

Mount the new filesystem (say, to `/mnt/keys`) and cd to it.

Create a keyfile

    dd if=/dev/urandom of=keyfile bs=1024 count=4

Add the keyfile to each encrypted disk

    cryptsetup luksAddKey /dev/sdc /mnt/sdf1/keyfile

    cryptsetup luksAddKey /dev/sdb /mnt/sdf1/keyfile

Add new mount point to /etc/fstab for USB disk

    /dev/disk/by-uuid/51b346cc-5141-44a9-aa99-fad3bb358693 /mnt/keys ext4 errors=remount-ro 0 1

Substituting the actual UUID (from blkid command) for the UUID above.

Edit `/etc/defaults/cryptdisks` and change the `CRYPTDISKS\_MOUNT=""` line
to `="/mnt/keys"`

        CYPTDISKS\_MOUNT="/mnt/keys"

### Reducing the Number of Times a Password Must Be Entered 

Fork this and modify to allow passing path to a key file, as well as the
password group a disk belongs to.

[https://github.com/gebi/keyctl\_keyscript]

> **NOTE**:
> 
> Currently a work in progress

## Opening Encrypted Disks After Boot

If you want to be able to boot the system without first having to open
encrypted disks (and being forced to be present at the console to enter
the password), add to the options parameter in the `/etc/crypttab` file the
option "noauto" for each encrypted device, and the same option to the
mountpoints within the encrypted devices to /etc/fstab.

To be able to open the encrypted devices over a remote connection, you'll
have to patch `/lib/cryptsetup/scripts/decrypt_keyctl` using the
`decrypt_keyctl.patch` patch file in this directory.

	cd /lib/cryptsetup/scripts
	patch decrypt_keyctl ~jwheaton/src/new-host-setup/decrypt_keyctl.patch

Why is this patch needed?  It originally uses the user keyring -- this patch
changes it to use the default session keyring.  The problem is that you run
the script as root (via `cryptdisks_start`), but the real user (e.g. jwheaton)
doesn't have privileges to change attributes (like the timeout) of root's
user keyring, leading to permission denied errors in the script.  Using the
default session keyring instead (one is created the first time a secret is
added to the default session keyring) avoids this problem altogether. More
information can be found on a blogpost about [working with the kernel
keyring].

I'm still having problems with keyring permissions.  With my Laptop (Ubuntu
16.10) I have permission problems if I patch decrypt_keyctl, and it works if
I don't.  I still don't completely understand why only the session keyring
can be used on one distribution, and only the user keyring on another.

After those setup steps are complete, your system will boot without attempting
to open the encrypted devices and mounting the contained filesystems.  You can
then remote to the host at your leisure and open encrypted devices and mount
filesystems like so:

	sudo cryptdisks_start enc1
	sudo cryptdisks_start enc2
	sudo cryptdisks_start enc3
	sudo mount /var/spool/burp
	sudo mount /mnt/media

## Configuring Windows Clients to Backup to Two Backup Servers

Section to be filled in.  May no longer be needed, as I might just use a cloud backup solution.

  [https://wiki.archlinux.org/index.php/systemd]: https://www.google.com/url?q=https://wiki.archlinux.org/index.php/systemd&sa=D&ust=1472810182470000&usg=AFQjCNEROwjhkC0q1tVlF4O1mT8yynJ3dQ
  [systemd-fstab-generator]: https://www.google.com/url?q=http://www.freedesktop.org/software/systemd/man/systemd-fstab-generator.html&sa=D&ust=1472810182552000&usg=AFQjCNG22289OhC2z8g677QmLtvlUyX7NA
  [1]: https://www.google.com/url?q=https://lists.debian.org/debian-user/2014/11/msg00033.html&sa=D&ust=1472810182553000&usg=AFQjCNFGRNL_MOZPnrrqKmNsX81H23mT9w
  [https://www.freedesktop.org/software/systemd/man/systemd-cryptsetup-generator.html]:
    https://www.google.com/url?q=https://www.freedesktop.org/software/systemd/man/systemd-cryptsetup-generator.html&sa=D&ust=1472810182558000&usg=AFQjCNE8eHdW136v5bUUAkjoux3-jKIHUA
  [https://btrfs.wiki.kernel.org/index.php/FAQ\#Does\_btrfs\_support\_swap\_files.3F]:
    https://www.google.com/url?q=https://btrfs.wiki.kernel.org/index.php/FAQ%23Does_btrfs_support_swap_files.3F&sa=D&ust=1472810182566000&usg=AFQjCNFWj_10lZMmC3UTd6E_avzbQQZU1Q
  [http://paxswill.com/blog/2013/11/04/encrypted-raspberry-pi/]: https://www.google.com/url?q=http://paxswill.com/blog/2013/11/04/encrypted-raspberry-pi/&sa=D&ust=1472810182572000&usg=AFQjCNFDk8bwajqAavbSW2AapaKQphaJVg
  [https://github.com/gebi/keyctl\_keyscript]: https://www.google.com/url?q=https://github.com/gebi/keyctl_keyscript&sa=D&ust=1472810182588000&usg=AFQjCNEyMW7a2XQdmPlbeMXOgldsxjR8RQ
  [working with the kernel keyring]: https://mjg59.dreamwidth.org/37333.html

vim:ft=markdown:sw=4:sts=4:tw=76
