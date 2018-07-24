#!/bin/bash
rm -rf blib
ppi_version change $1 $2
#$1 is the old version
#$2 is the new version
git add lib
git add t
git commit -m "prepare new release"
git push
git tag -a $2
git push origin --tags
make
