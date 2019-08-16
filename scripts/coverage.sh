#!/bin/bash
perl Makefile.PL
touch Makefile
make
cover -test