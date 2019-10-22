#!/bin/bash

sudo rm -f /root/.ssh/known_hosts

sshpass -p 'vagrant' sudo scp -o StrictHostKeyChecking=no util.io:/etc/docker/certs.d/util.io/ca.crt /etc/docker/certs.d/util.io

docker login --username=testuser --password=testpassword util.io
