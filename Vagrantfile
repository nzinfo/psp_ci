Vagrant.configure("2") do |config|
  
  config.vm.box = "ubuntu/focal64"
  
  # hostmanager.
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  # proxy setting
  if Vagrant.has_plugin?("vagrant-proxyconf") && ENV["HTTP_PROXY"]
      config.proxy.http     = ENV["HTTP_PROXY"]
      config.proxy.https    = ENV["HTTP_PROXY"]
      config.proxy.no_proxy = "localhost,127.0.0.1"
  end

  #turn vbguest auto update on.
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  # pass global env to vm. eg. secret key to aliyun ? 
  provision_environment = {
    "VAULT_AUTH_TOKEN" => ENV["VAULT_AUTH_TOKEN"],
    "GIT_SERVER_IP" => ENV["PDEV_GIT_IP"] || '192.168.62.22',
    "CI_SERVER_IP" => ENV["PDEV_CI_IP"] || '192.168.62.22',
    "GIT_SERVER_NAME" => "git.local",
    "CI_SERVER_NAME" => "cu.local"
  }

  # As of VirtualBox 6.1.28, host-only network adapters are restricted to IPs 
  # in the range 192.168.56.0/21 by default (192.168.56.1 -> 192.168.63.254).
  config.vm.define 'git-box' do |gitnode|

    gitnode.vm.hostname = 'gitea'
    gitnode.vm.network :private_network, ip: provision_environment['GIT_SERVER_IP']
    # 注意别名: git.local 表示是本地 git 服务的抽象概念，当使用一般意义上的 git 服务时引用； gitea.pdev 表示是 具象的 gitea 承载，
    gitnode.hostmanager.aliases = %w(git.local gitea.pdev ci.local drone.pdev)
    
    # git usage
    gitnode.vm.network "forwarded_port", guest: 8080, host: 8080
    gitnode.vm.network "forwarded_port", guest: 8022, host: 8022
    # drone usage

    # customized virtualbox
    gitnode.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
      v.gui = false

      # Use the hosts DNS resolution.  This is meant to speed things up and also
      # allow resolution of addresses from a VPN
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

    # NOTE: Be careful here, the VM has access to *everything* in the home
    # directory on the host machine
    gitnode.vm.synced_folder ENV["HOME"]+"/personal_ci", "/vagrant_data", owner: "vagrant", group: "vagrant"
    ## config.vm.synced_folder ENV["HOME"]+"/personal_ci", "/vagrant_home",  owner: "vagrant", group: "vagrant", \
      # type: "nfs", mount_options: ['nolock,vers=3,udp,noatime,actimeo=1']

    # provision only once.
    gitnode.vm.provision "shell", env: provision_environment , path: "provisions/setup.sh"
      
    # start each time vm boot.
    gitnode.vm.provision "shell", env: provision_environment , run: "always", path: "provisions/startup.sh"

  end

  # Setup mirrors
  # config.vm.provision :shell, :inline => "sed -i 's|deb http://archive.ubuntu.com.ubuntu|deb mirror://mirrors.ubuntu.com/mirrors.txt|g' /etc/apt/sources.list"
  # config.vm.provision "shell", inline: "sed -i '/deb-src/d' /etc/apt/sources.list"
  # config.vm.provision "shell", inline: "apt-get update -y"

end
