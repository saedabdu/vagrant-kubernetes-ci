#!/bin/bash

set -e

if [[ -z "${2}" ]]; then
    echo "Cluster type is not set, normal ubuntu machine will provision instead!"
else
    if [[ "${2}" == "swarm" ]]; then
        sudo docker swarm join --token `cat /vagrant/.join-token-worker` "$1:2377"
    elif [[ "${2}" == "k8s" ]]; then
        sudo `cat /vagrant/.k8s-join-cmd`
    fi
fi