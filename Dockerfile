# Dockerfile for docker-nestjs-config
#
#####################
# Build Dependencies:
# - Expects dist (dir containing built distribution of apiserver) as a subdir from where Dockerfile exists
# - Expects docker-bin/node.sh startup script to be present in build dir
#   This file starts node with appropriate settings
#     - Expects environment variables:
#       $NVM_DIR to point at
#       $NODE_VERSION to point at
#       $SRV_ROOT to point at
#
#   Note: this file can sometimes get converted to Windows EOL format, which will cause startup failure.  To check this:
#   run file command, with:
#   $ file docker-bin/node.sh
#     it should come back as " POSIX shell script, ASCII text executable"
#     if it comes back as "POSIX shell script, ASCII text executable, with CRLF line terminators", it must be converted.
#   To convert (install with apt-get install dos2unix if needed):
#   $ dos2unix docker-bin/node.sh
#
####################
# Build Steps:
# 1) run: npm run build:docker to build the docker image
#
####################
# Running Locally
#
### Must provide following Environment Variables
#
# NODE_ENV=production
# ? PORT=
#
########
# These can be provided in multiple ways:
# 1) in the container itself, with plain old .env file
# 2) via docker run - e.g., docker run --rm -it --env-file .env.docker-local server -p 8888:3000
# 3) via docker compose
#
# or on the command line:
# $ docker run --rm -it \                   # -it for interactive testing; for deploy, use -d
#                --env DB_HOST=192.168.2.90 server \
#                -p 8888:8888#
#
#####################
#####################
# About phusion/baseimage
# - as of 3/1/19, latest is 0.11
# 0.11 specs
# - Ubuntu 18.04 LTS
# - uses a specialized init process: /sbin/my_init, to deal with containerization
#   of Ubuntu more appropriately
# - uses runit (instead of Upstart or systemd) for the init system
#
#  -- How runit works --
# http://smarden.org/runit/
# - to enable a service, create a folder in /etc/service, and add an executable file
#   called run (a shell script, see node.sh for an example)
# - start/stop/restart with sv up/sv down/sv restart
####################
####################
# --- END OF DOCUMENTATION ---
#
# --- History ---
#
# 2019-07-13 - John Biundo <johnfbiundo@gmail.com>
# - initial version
#
######################################################
######################################################
# BUILD
######################################################

# 0.11 is latest as of 3/1/19
# should specify a version, rather than :latest, to ensure that we don't
# have a dependency on a baseimage that changes
FROM  phusion/baseimage:0.11
LABEL MAINTAINER="johnfbiundo@gmail.com"

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set up for node install
ENV NODE_VERSION=12.6.0
ENV NODE_ENV='production'
RUN mkdir /usr/local/nvm
ENV NVM_DIR=/usr/local/nvm

# Install NVM & node
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# container will listen on SRV_PORT
# map this to a host port in compose file or docker run command (-p <host:container>)
ENV SRV_ROOT='/server' \
  SRV_PORT=3000

WORKDIR $SRV_ROOT
RUN mkdir dist
COPY dist dist
COPY package.json .
RUN npm install

EXPOSE $SRV_PORT

# following creates a a runit service that is started at container startup
RUN mkdir /etc/service/node
ADD ./docker-bin/node.sh /etc/service/node/run
RUN chmod +x /etc/service/node/run
