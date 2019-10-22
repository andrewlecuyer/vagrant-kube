# bootstrap cluster
def bootstrap_cluster(config)

    config.vm.provision "shell", inline: <<-SHELL
    kubeadm init \
      --apiserver-advertise-address=172.28.2.2 \
      --ignore-preflight-errors=NumCPU \
      | grep 'kubeadm join' -A 1 > /home/vagrant/join-command.sh
    SHELL

end

# prepare kube config for use by kubectl
def prepare_master_kubeconfig(config)

    config.vm.provision "shell", inline: <<-SHELL
    mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown vagrant:vagrant /home/vagrant/.kube/config
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    SHELL

end

# deploy weave net
def deploy_weavenet(config)
    
    config.vm.provision "shell", inline: <<-SHELL
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
    SHELL

end
