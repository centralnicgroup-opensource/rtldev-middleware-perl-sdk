#!/bin/bash

# THIS SCRIPT UPDATES THE HARDCODED VERSION
# IT WILL BE EXECUTED IN STEP "prepare" OF
# semantic-release. SEE package.json

# version format: X.Y.Z
newversion="$1";
branch="$2";

if [ "$branch" = "master" ]; then
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet/Connector.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet/Connector/APIClient.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet/Connector/Column.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet/Connector/Record.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet/Connector/Response.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet/Connector/ResponseParser.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet/Connector/ResponseTemplate.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet/Connector/ResponseTemplateManager.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" lib/WebService/Hexonet/Connector/SocketConfig.pm
    sed -i "s/declare('v[0-9]\+\.[0-9]\+\.[0-9]\+')/declare('v${newversion}')/g" t/Hexonet-connector.t
fi;