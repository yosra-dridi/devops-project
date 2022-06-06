#!/bin/bash

sudo sed -i "s/#PermitRootLogin/PermitRootLogin/" /etc/ssh/sshd_config
sudo sed -i "s/^.*ssh/ssh/" /root/.ssh/authorized_keys
sudo service sshd restart