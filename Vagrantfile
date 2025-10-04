Vagrant.configure("2") do |config|
  # USE THE MOST UNIVERSAL BOX NAME: Vagrant will infer ARM/VMware compatibility
  config.vm.box = "bento/ubuntu-22.04"

  config.vm.network "forwarded_port", guest: 8000, host: 8000

  # We rely entirely on Fusion Pro 13+ to handle the VMX fixes automatically.
  config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "4096"
    v.vmx["numvcpus"] = "2"
  end

  # PROVISIONING SCRIPT (Python setup)
  config.vm.provision "shell", inline: <<~PROVISION
    sudo add-apt-repository -y universe
    sudo apt-get update
    sudo apt-get install -y python3-pip python3.10-venv zip python3-distutils

    touch /home/vagrant/.bash_aliases
    if ! grep -q PYTHON_ALIAS_ADDED /home/vagrant/.bash_aliases; then
      echo "# PYTHON_ALIAS_ADDED" >> /home/vagrant/.bash_aliases
      echo "alias python='python3'" >> /home/vagrant/.bash_aliases
    fi
    source /home/vagrant/.bash_aliases
  PROVISION
end
