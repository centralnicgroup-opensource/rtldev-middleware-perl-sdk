#!/bin/bash
perl Makefile.PL && make && cover -test
rm -rf blib
ppi_version change "$1" "$2"
#$1 is the old version
#$2 is the new version
./scripts/rebuild.sh
make
