Vagrant.configure("2") do |config|
  config.vm.box = "cloud-image/debian-12"
  config.vm.box_version = "20250703.2162.0"
  config.vm.synced_folder "./data", "/data" ,type: "nfs" ,nfs_version: 4
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y puppet
    /data/payload.sh
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    systemctl restart sshd
    echo "root:vagrant" | chpasswd
  SHELL
end
