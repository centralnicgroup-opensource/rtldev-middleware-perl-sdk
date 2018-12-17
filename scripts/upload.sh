#!/bin/bash
cpan-upload -u "$CPAN_USER" -p "$CPAN_PASSWORD" --md5 WebService-Hexonet-Connector-"$1".tar.gz