#!/bin/sh -xe

cd terraform/

terraform init
terraform apply -auto-approve

terraform output inventory > ../ansible/inventory.ini
terraform output exports > ../import.sh

cd -

. ./import.sh

# Install prerequisites for ansible
ssh -o StrictHostKeyChecking=no centos@${JUMP_SERVER_IP} 'mkdir -p ~/ansible'
ssh -o StrictHostKeyChecking=no centos@${JUMP_SERVER_IP} 'sudo yum install -y python3'
ssh -o StrictHostKeyChecking=no centos@${JUMP_SERVER_IP} 'sudo pip3 install ansible'

scp -r ./ansible/* centos@${JUMP_SERVER_IP}:~/ansible

# Prepare key
ssh -o StrictHostKeyChecking=no centos@${JUMP_SERVER_IP} 'rm -f ~/.ssh/id_rsa'
ssh -o StrictHostKeyChecking=no centos@${JUMP_SERVER_IP} 'mkdir -p ~/.ssh'
scp -o StrictHostKeyChecking=no ~/.ssh/id_rsa centos@${JUMP_SERVER_IP}:~/.ssh/id_rsa
ssh -o StrictHostKeyChecking=no centos@${JUMP_SERVER_IP} 'chmod 400 ~/.ssh/id_rsa'

# Run playbook
ssh -o StrictHostKeyChecking=no centos@${JUMP_SERVER_IP} 'cd ansible/ && ansible-playbook playbook.yaml -i inventory.ini'

# Cleanup private key
ssh -o StrictHostKeyChecking=no centos@${JUMP_SERVER_IP} 'rm -f ~/.ssh/id_rsa'

echo ${APP_URL}