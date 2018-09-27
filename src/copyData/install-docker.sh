#!/usr/bin/env bash
# install docker on a node


DOCKER_EE_URL="https://download.docker.com/linux"
LSB_RELEASE=`lsb_release -cs`

apt-get -y remove docker docker-engine docker-ce docker.io
apt-get update -y
apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL ${DOCKER_EE_URL}/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] ${DOCKER_EE_URL}/ubuntu ${LSB_RELEASE} stable"
apt-get update -y && apt-get install docker-ce -y
usermod -aG docker $USER