#!/bin/bash
rm MANIFEST WebService-Hexonet-"$1".tar.gz
perl Makefile.PL &&
    make && cover -test &&
    make manifest &&
    make tardist
cp WebService-Hexonet-Connector-"$1".tar.gz WebService-Hexonet-Connector-latest.tar.gz
cp WebService-Hexonet-Connector-"$1".tar.gz WebService-Hexonet-Connector.tar.gz