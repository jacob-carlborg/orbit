#!/bin/sh

rdmd --build-only -oforb -Iorange -L-lruby.1.9.1-static -J./resources -L-lz "$@" orbit/orb/Orb.d