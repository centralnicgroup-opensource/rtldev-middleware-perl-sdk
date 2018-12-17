#!/bin/bash
rm  WebService-Hexonet-Connector-"$1".tar.gz
make manifest && make tardist
cp WebService-Hexonet-Connector-"$1".tar.gz WebService-Hexonet-Connector-latest.tar.gz
cp WebService-Hexonet-Connector-"$1".tar.gz WebService-Hexonet-Connector.tar.gz