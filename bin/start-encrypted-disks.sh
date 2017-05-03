#! /bin/bash

# This script starts the encrypted disks, mounts any subvolumes, and then
# starts the services that depend on those encrypted disks.

logfile="$(basename $0)-$(date +%FT%T).log"

# Iterate over the lines in /etc/crypttab.
get_crypttab_entries() {
}

# Iterate over the "noauto" optioned lines in /etc/fstab
get_fstab_entries() {
}

do_stuff() {
    # start devices in /etc/crypttab.
    cryptdisks_start enc1

    # mount the "noauto" devices.
    mount /home2
}

do_stuff 2>&1 | tee $logfile

# vim:tw=76:sts=4:sw=4
