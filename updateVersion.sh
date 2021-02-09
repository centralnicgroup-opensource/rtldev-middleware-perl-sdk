#!/bin/bash

# THIS SCRIPT UPDATES THE HARDCODED VERSION
# IT WILL BE EXECUTED IN STEP "prepare" OF
# semantic-release. SEE package.json

# version format: X.Y.Z
newversion="$1";

printf -v sed_script "s/our \$VERSION = 'v[0-9]\+\.[0-9]\+\.[0-9]\+'/our \$VERSION = 'v%s'/g" "${newversion}"
sed -i -e "${sed_script}" t/*.t lib/WebService/*.pm lib/WebService/Hexonet/*.pm lib/WebService/Hexonet/Connector/*.pm
