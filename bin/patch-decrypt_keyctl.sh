#! /bin/bash

logfile="$(basename $0)-$(date +%FT%T).log"

pushd $(dirname $0)
MYDIR_=$(pwd)
popd

do_stuff() {
    pushd /lib/cryptsetup/scripts
    patch decrypt_keyctl $MYDIR_/../setup-files/decrypt_keyctl.patch
    if [ $? -ne 0 ]; then
        die "Error patching /lib/cryptsetup/scripts/decrypt_keyctl. You'd better investigate."
    fi
    popd
}

do_stuff 2>&1 | tee $logfile

# vim:sts=4:sw=4:tw=76
