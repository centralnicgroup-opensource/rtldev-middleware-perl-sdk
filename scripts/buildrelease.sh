#!/bin/bash
perl Makefile.PL && make && cover -test && make tardist
