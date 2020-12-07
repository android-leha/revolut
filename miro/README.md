
# Miro Homework

## Description

- LB: EC2 VM with HAproxy
- APP: 3 EC2 VMs with Nginx and PHP-FPM
- DB: EC2 VM with Postgresql

All components are running in dockers containers

Each component has its own subnet: Public for LB and 2 Private for APPs and DB.
A public subnet connected to internet with Internet Gateway and private - with NAT Gateway.


## Prerequisites

1. Git Bash or compatible shell 
2. terraform 
3. AWS API key
4. AWS Secret key
5. Key pair in ~/.ssh


## Usage

Archive is bundled with run.sh which could do all the work.

However, it can require some changes to adopt it to your environment.

I took assumption that LB is a Jump server for entire installation.
I did it, because of problems with running ansible on Windows host. 


### Flow

1. Create infrastructure with terraform
2. Copy ansible scripts and inventory to JUMP server
3. Run ansible installation

## How to improve

1. Implement HA with creating 2 subnets for each component in different AZ.
2. Usage managed services: 
   - ALB instead of LB
   - EKS instead of APPs
   - RDS instead of Postgresql
3. Implement TLS
4. DB backups
