# install node packages
def install_node_packages(config)

    config.vm.provision "shell", inline: <<-SHELL
    yum install -y google-cloud-sdk
    SHELL

end

# install node yum repos
def install_node_repos(config)

      config.vm.provision "shell", inline: <<-SHELL
      sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
      SHELL
  
  end 
 
# fetch .kube config from master
def fetch_kubeconfig(config)

    config.vm.provision "shell", inline: <<-SHELL
    sshpass -p 'vagrant' scp -r -o StrictHostKeyChecking=no vagrant@master:.kube /home/vagrant
    chown vagrant:vagrant /home/vagrant/.kube/config
    sshpass -p 'vagrant' scp -r -o StrictHostKeyChecking=no vagrant@master:.kube /root
    chown root:root /root/.kube/config
    SHELL

end

# obtain and execute kubeadm join command from master to join node to cluster
def join_cluster(config)

    config.vm.provision "shell", inline: <<-SHELL
    sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no vagrant@master:join-command.sh /home/vagrant
    chmod +x /home/vagrant/join-command.sh
    ./join-command.sh 
    SHELL

end

# add route to ensure private interface (and not the default interface) is used for communication
def config_iptables_for_weavenet(config)

    config.vm.provision "shell", inline: <<-SHELL
    ip route add 10.96.0.0/12 dev eth1
    bash -c "echo '10.96.0.0/12 dev eth' >> /etc/sysconfig/network-scripts/route-eth1"
    SHELL

end

# install local docker registry cert and login
def config_local_docker_registry(config)

    config.vm.provision "shell", inline: <<-SHELL
    mkdir /etc/docker/certs.d/util.io
    sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no util.io:/etc/docker/certs.d/util.io/ca.crt /etc/docker/certs.d/util.io
    docker login --username=testuser --password=testpassword util.io
    SHELL

end

# login to docker as vagrant user (command executed privileged)
def docker_login_vagrant(config)

    config.vm.provision "shell", privileged: false, inline: <<-SHELL
    docker login --username=testuser --password=testpassword util.io
    SHELL

end
