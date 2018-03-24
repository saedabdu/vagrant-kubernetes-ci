#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

installDocker () {
    sudo apt-get update \
        && sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual \
        && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common \
        && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
        && sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable" \
        && sudo apt-get update \
        && sudo apt-get install -y docker-ce \
        && sudo usermod -aG docker vagrant \
        && sudo service docker start
}

installDockerCompose () {
    sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose \
        && sudo chmod +x /usr/local/bin/docker-compose
}

installK8s () {
    sudo apt-get update \
        && sudo apt-get install -y apt-transport-https ca-certificates software-properties-common curl docker.io=\1.13* \
        && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
        && sudo sh -c 'echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list' \
        && sudo apt-get update \
        && sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
}

installJenkins () {
    sudo apt-get update \
        && sudo apt-get install openjdk-8-jre-headless -y \
        && wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add - \
        && sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' \
        && sudo apt-get update \
        && sudo apt-get install jenkins -y \
        && sudo systemctl start jenkins.service
}

addJenkinsKey () {
if [ ! -f "/var/lib/jenkins/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -N "" -f /var/lib/jenkins/.ssh/id_rsa
fi
cp /var/lib/jenkins/.ssh/id_rsa.pub /vagrant/jenkins.pub
cat << 'SSHEOF' > /var/lib/jenkins/.ssh/config
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
SSHEOF
chown -R jenkins:jenkins /var/lib/jenkins/.ssh
}

if [[ $# -gt 0 ]]; then
    if [[ "$1" == "swarm" ]]; then
        installDocker
    elif [[ "$1" == "jenkins" ]]; then
        installJenkins
        addJenkinsKey
        installDocker
        installDocerCompose
        installK8s
        # Add jenkins to Docker group
        sudo usermod -aG docker jenkins
    elif [[ "$1" == "k8s" ]]; then
        installK8s
    fi
fi