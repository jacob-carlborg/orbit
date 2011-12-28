#!/bin/sh

rdmd --force --build-only -ofbin/orb -Iorange -I../Tango-D2 -L-lruby-static -L-L../Tango-D2 -L-ltango -L-ldl -L-lcrypt -J./resources -L-lz "$@" orbit/orb/Orb.d
