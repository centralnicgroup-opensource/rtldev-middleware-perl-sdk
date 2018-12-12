#!/bin/bash
# -php is abbreviation for
# -l=78 -i=4 -ci=4 -st -se -vt=2 -cti=0 -pt=1 -bt=1 -sbt=1 -bbt=1 -nsfs -nolq -wbb="% + - * / x != == >= <= =~ !~ < > | & = **= += *= &= <<= &&= -= /= |= >>= ||= //= .= %= ^= x="

perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' Makefile.PL
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet/Connector.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet/Connector/APIClient.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet/Connector/Column.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet/Connector/Record.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet/Connector/Response.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet/Connector/ResponseParser.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet/Connector/ResponseTemplate.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet/Connector/ResponseTemplateManager.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' lib/WebService/Hexonet/Connector/SocketConfig.pm
perltidy -q -pbp -nst -i=4 -ce -bar -pt=1 -bt=1 -sbt=0 -aws -dws -l=0 -blbs=2 -nbbc -mbl=1 -kbl=1 -b -bext='/' t/Hexonet-connector.t

        
        
        
        
