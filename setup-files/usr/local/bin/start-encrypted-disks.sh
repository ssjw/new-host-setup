#! /bin/bash

# This script starts the encrypted disks, mounts any mount points with the
# noauto option, and then runs any executable files found in
# /usr/local/etc/post-open-encrypted-devices-commands.d/<hostname>/

logfile="$(basename $0)-$(date +%FT%T).log"

# Iterate over the lines in /etc/crypttab.
get_crypttab_entries() {
    gawk -- 'BEGIN{FS=" "}$0 !~ /^\s*#/{print $1}' /etc/crypttab
}

# Iterate over the "noauto" optioned lines in /etc/fstab
get_fstab_entries() {
    grep -v "^\s*#" /etc/fstab | gawk -- 'BEGIN{FS=" "}/noauto/{print $2}' -
}

get_services_entries() {
    gawk -- 'BEGIN{FS=" "}$0 !~ /^s*#/print $1}' $1
}

do_stuff() {
    # start devices in /etc/crypttab.
    for i in $(get_crypttab_entries); do
        echo "Starting encrypted device ${i}..."
        cryptsetup status ${i} | head -1 | grep -qs "\<active\>"
        if [ $? == 0 ]; then
            echo "${i} is already active, skipping."
        else
            cryptdisks_start ${i}
            if [ $? == 1 ]; then
                >&2 echo "Failed to open encrypted device ${i}. Aborting." 
                exit 1
            fi
        fi
    done

    # mount the "noauto" devices.
    for i in $(get_fstab_entries); do
        echo "Mounting encrypted device at mount point ${i}..."
        mount | grep -qs "${i}"
        if [ $? == 0 ]; then
            echo "${i} is already mounted, skipping."
        else
            echo "Mounting ${i}"
            mount ${i}
            if [ $? == 1 ]; then
                >&2 echo "Failed to mount ${i}. Aborting"
                exit 1
            fi
        fi
    done

    # Run host specific commands if they exist.
    post_open_dir=/usr/local/etc/services.d
    this_host=$(hostname -s)
    services_file=${post_open_dir}/${this_host}
    if [ -f ${services_file} ]; then
        for i in $(get_services_entries ${services_files}); do
            start-services ${i}
        done
    else
        echo "No host specific services file ${services_file} for ${this_host} in"
        echo "${post_open_dir}"
    fi
}

do_stuff 2>&1 | tee $logfile

# vim:tw=76:sts=4:sw=4
