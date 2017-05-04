#! /bin/bash

# This script starts the encrypted disks, mounts any subvolumes, and then
# starts the services that depend on those encrypted disks.

logfile="$(basename $0)-$(date +%FT%T).log"

# Iterate over the lines in /etc/crypttab.
get_crypttab_entries() {
    gawk -- 'BEGIN{FS=" "}$0 !~ /^\s*#/{print $1}' /etc/crypttab
}

# Iterate over the "noauto" optioned lines in /etc/fstab
get_fstab_entries() {
    grep -v "^\s*#" /etc/fstab | gawk -- 'BEGIN{FS=" "}/noauto/{print $2}' -
}

do_stuff() {
    # start devices in /etc/crypttab.
    for i in get_crypttab_entries; do
        echo "starting encrypted device ${i}..."
        cryptdisks_start ${i}
    done

    # mount the "noauto" devices.
    for i in get_fstab_entries; do
        echo "mounting encrypted device at mount point ${i}..."
        mount ${i}
    done
}

do_stuff 2>&1 | tee $logfile

# vim:tw=76:sts=4:sw=4
