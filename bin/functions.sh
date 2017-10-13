#! /bin/bash

# This function will determine if apt-get update has been run within the
# specified number of minutes, with a default of 1 day.
apt_cache_updated_within_minutes () {
    if [ -n "$1" ]; then
        minutes=$1
    else
        minutes=1440
    fi

    if [ -n "$(find /var/cache/apt/ -daystart -maxdepth 1 \
        -mmin -${minutes} -type f -name pkgcache.bin)" ]; then
        return 0
    else
        return 1
    fi
}

# Run apt-get update only if it hasn't been run within the last day.
apt_get_update () {
    apt_cache_updated_within_minutes 1440
    if [ $? == 1 ]; then
        apt-get update
    fi
}
