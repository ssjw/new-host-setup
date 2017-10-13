#! /usr/bin/bash

# This attempts to kill old mosh servers which have been disconnected.
# Found on the Web.

for server in $(ps aux | awk '/mosh-server/ { print $2 }'); do
    for bash in $(ps --ppid $server | awk '/bash/ { print $1 }'); do
        test $(ps --ppid $bash | wc -l) = 1 && kill $server;
    done;
done

