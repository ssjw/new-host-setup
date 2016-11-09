# Configuration for Debian on 2015 XPS 13 (9343)

## Current working configuration

- Debian Stretch (current testing, but what will become the next stable
    version)
- Linux kernel 4.7.0 (apparently included in Stretch as of 2016-11-09)

## What needed configuration by hand

- Wireless driver install

## What's working out of the box

- Display
- Sound + mic (although someone said it sounded like I was talking through a
  tin can)
- touch pad (and very well I might add)
- suspend

## What I haven't tried to get working

- Hibernate (I never use it... I can suspend for a couple of days without
    much visible depletion of the battery and startup is instantaneous)

## Getting wireless to work

This was pretty easy, actually, but finding the information on how to get it
to work with kernel 4.7.0 took some investigation and a few reboots.
Basically it required installing the Debian package `broadcom-sta-source`
plus some commands to compile the source and install.

1. Install `broadcom-sta-source`
2. As root, run:

        module-assistant prepare broadcom-sta
        module-assistant auto-install broadcom-sta

  to compile the kernel module, create a Debian package, and install it.
3. To use immediately, run:

        modprobe wl

vim:ts=2:sw=2:sts=2:tw=76
