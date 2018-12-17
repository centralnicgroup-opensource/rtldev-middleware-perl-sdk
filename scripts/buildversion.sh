#!/bin/bash
# buildversion
rm MANIFEST WebService-Hexonet-"$1".tar.gz
perl Makefile.PL && make && cover -test
rm -rf blib
ppi_version change "$1" "$2"
#$1 is the old version
#$2 is the new version
./scripts/rebuild.sh

# buildrelease
perl Makefile.PL && make && cover -test && make manifest && make tardist
cp WebService-Hexonet-Connector-"$1".tar.gz WebService-Hexonet-Connector-latest.tar.gz
cp WebService-Hexonet-Connector-"$1".tar.gz WebService-Hexonet-Connector.tar.gz