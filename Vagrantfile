Vagrant.configure("2") do |config|
  
  config.vm.box = "ubuntu/focal64"
  #config.vm.network "forwarded_port", guest: 80, host: 8080
  #config.vm.network "forwarded_port", guest: 8043, host: 8043
  #config.vm.network "forwarded_port", guest: 22, host: 8022
  
  config.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 2
      v.gui = false

      # Use the hosts DNS resolution.  This is meant to speed things up and also
      # allow resolution of addresses from a VPN
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end
  # 
  config.vm.hostname = "git-podman-host"

  # pass global env to vm.
  provision_environment = {
    "VAULT_AUTH_TOKEN" => ENV["VAULT_AUTH_TOKEN"]
  }

  # NOTE: Be careful here, the VM has access to *everything* in the home
  # directory on the host machine
  config.vm.synced_folder ENV["HOME"]+"/personal_ci", "/vagrant_home", owner: "vagrant", group: "vagrant"

  config.vm.provision "shell", env: provision_environment , inline: <<-SHELL
    # Install packages - note, no need to link node to nodejs, this is done already
    apt update && apt install -y build-essential curl ruby unzip nodejs git

    # ###### #
    # PODMAN #
    # ###### #
    . /etc/os-release
    echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
    curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | apt-key add -
    apt-get update
    apt-get -y upgrade
    apt-get -y install podman
  
  SHELL

end