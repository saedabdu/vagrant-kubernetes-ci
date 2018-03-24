#!/bin/bash

set -e

if [[ -z "${2}" ]]; then
    echo "Cluster type is not set, normal ubuntu machine will provision instead!"
else
    if [[ "${2}" == "swarm" ]]; then
        sudo docker swarm init --advertise-addr $1 --listen-addr $1
        sudo docker swarm join-token -q worker > /vagrant/.join-token-worker
    elif [[ "${2}" == "k8s" ]]; then
        sudo kubeadm init \
            --apiserver-advertise-address $1 \
            --pod-network-cidr=10.244.0.0/16 > /vagrant/.k8s-init.log 2>&1 \
        && cat /vagrant/.k8s-init.log | grep -Pzo 'kubeadm\s(.*)*' > /vagrant/.k8s-join-cmd \
        && su - vagrant -c "sh /vagrant/scripts/k8s_user_init.sh"
    fi
fi