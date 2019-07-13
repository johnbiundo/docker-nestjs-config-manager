#!/bin/sh
# Expects following environment variables to be set.
# These can be set in the docker build step, or at run/deploy time
#
# If used in docker, ensure that this file has linux line endings.
# Check with file node.sh
# If necessary, convert with dos2unix node.sh
#
# NVM_DIR = where nvm will be installed.  Usually /usr/local/nvm
# NODE_VERSION
# SRV_ROOT = the directory where the dist will be created
#
echo 'starting node at '
echo $NVM_DIR/versions/node/v$NODE_VERSION/bin

# start a service in runit with exec
#
# following line shows how to set node avail mem to 4GB
# exec node --max-old-space-size=4096 $SRV_ROOT/server/app.js
exec node $SRV_ROOT/dist/main.js
echo 'started Server...'