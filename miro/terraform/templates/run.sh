#!/bin/sh -x

# Install prerequisites
ssh centos@${jump} 'mkdir -p ~/ansible'
ssh centos@${jump} 'sudo yum install -y python3'
ssh centos@${jump} 'sudo pip3 install ansible'

scp -r ./ansible/* centos@${jump}:~/ansible

# Prepare key
ssh centos@${jump} 'mkdir -p ~/.ssh'
scp ~/.ssh/id_rsa centos@${jump}:~/.ssh/id_rsa
ssh centos@${jump} 'chmod 400 ~/.ssh/id_rsa'

ssh centos@${jump} 'ansible-playbook ansible/playbook.yaml -i ansible/inventory.ini'

ssh centos@${jump} 'rm -f ~/.ssh/id_rsa'