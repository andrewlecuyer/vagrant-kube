# configure dns
def config_dns(config)
  
    config.vm.provision "shell", inline: <<-SHELL
    rm -f /etc/resolv.conf
    printf "nameserver 8.8.8.8\n" >> /etc/resolv.conf
    printf "nameserver 8.8.4.4\n\n" >> /etc/resolv.conf
    SHELL
    
end

# initial configuration of the hosts file
def config_hosts(config)
  
    config.vm.provision "shell", inline: <<-SHELL
    printf "172.28.2.2 master\n" >> /etc/hosts
    printf "172.28.2.12 node01\n" >> /etc/hosts
    
    printf "\n172.28.1.2 util\n" >> /etc/hosts
    printf "172.28.1.2 util.io\n\n" >> /etc/hosts
    SHELL
    
end

# enable ssh username and password authentication
def enable_ssh_user_pass(config)
  
    config.vm.provision "shell", inline: <<-SHELL
    sed -E -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd
    SHELL
    
end

# disable swap
def disable_swap(config)

    config.vm.provision "shell", inline: <<-SHELL
    swapoff -a
    sed -E -i 's/.+swap.+/#&/' /etc/fstab
    SHELL

end

# install common yum repos
def install_common_repos(config)
   
    config.vm.provision "shell", inline: <<-SHELL
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    SHELL

end

# install common packages
def install_common_packages(config)

    config.vm.provision "shell", inline: <<-SHELL
    yum install -y --disableexcludes=kubernetes \
      telnet \
      sshpass \
      docker \
      kubelet kubeadm kubectl
    SHELL

end

# enable kubelet
def enable_kubelet(config)
    
    config.vm.provision "shell", inline: <<-SHELL
    systemctl enable kubelet
    systemctl start kubelet
    SHELL

end

# enable docker
def enable_docker(config)

  config.vm.provision "shell", inline: <<-SHELL
  systemctl enable docker
  systemctl start docker
  groupadd docker
  usermod -a -G docker vagrant
  SHELL

end

# disable selinux
def disable_selinux(config)

  config.vm.provision "shell", inline: <<-SHELL
  setenforce 0
  sed -E -i 's/=enforcing/=permissive/' /etc/selinux/config
  SHELL

end

# configure iptables
def config_iptables(config)

    config.vm.provision "shell", inline: <<-SHELL
    printf "net.bridge.bridge-nf-call-ip6tables = 1\n" >> /etc/sysctl.d/k8s.conf
    printf "net.bridge.bridge-nf-call-iptables = 1\n" >> /etc/sysctl.d/k8s.conf
    SHELL
  
end
