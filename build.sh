#!/bin/sh

rdmd --build-only -oforb -L-lruby.1.9.1-static -J./resources -L-lz "$@" orbit/orb/Orb.d