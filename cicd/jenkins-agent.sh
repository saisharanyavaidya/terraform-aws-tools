#!/bin/bash

yum install fontconfig java-17-openjdk -y #java installation is must in AGENT node for Master to connect or to run any code in agent
#installing terraform -- this will be helpful to create infra using jenkins like to run 01-vpc in expense-infra-dev project 
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform
#installing nodejs for expense backend application
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
yum install zip -y