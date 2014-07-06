#!/bin/sh

if [ -s "$HOME/.dvm/scripts/dvm" ] ; then
    . "$HOME/.dvm/scripts/dvm" ;
    dvm use 2.065.0
fi

rdmd --build-only -ofbin/orb -m32 -Idstack -Idstack/mambo -L-lruby.1.9.1-static -J./resources -L-ltango -L-lz "$@" orbit/orb/Orb.d