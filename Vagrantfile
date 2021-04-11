require 'ostruct'
require 'yaml'
filepath = File.join(File.dirname(File.expand_path(__FILE__)))
::VM = OpenStruct.new(YAML.load_file("#{filepath}/config/vagrantfile.yaml"))

Vagrant.require_version ">= 2.0.0"
Vagrant.configure("2") do |config|
  config.vm.define VM.machine[:hostname]

  # https://app.vagrantup.com/bento/boxes/centos-6/versions/202103.18.0
  config.vm.box = "bento/centos-6" # 64GB HDD
  config.vm.box_version = "202103.18.0"
  config.vm.provider "virtualbox" do |vb|
    vb.name   = VM.machine[:hostname]
    vb.memory = VM.machine[:memory]
    vb.cpus   = VM.machine[:cpus]
  end

  # vagrant@centos-6-10
  config.vm.hostname = VM.machine[:hostname]

  # Disable default dir sync
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Synchronize code and VM folders
  config.vm.synced_folder VM.vm_path[:host], VM.vm_path[:guest], owner: "vagrant", group: "vagrant"
  config.vm.synced_folder VM.synced_folder[:host], VM.synced_folder[:guest], owner: "vagrant", group: "vagrant"

  # Apache: http://localhost:8000
  VM.forwarded_ports.each do |port_options|
    config.vm.network :forwarded_port, port_options
  end

  # Copy files from host machine
  VM.copy_files.each do |file_options|
    config.vm.provision :file, file_options
  end unless VM.copy_files.nil?

  # Provision bash script
  config.vm.provision :shell, path: "centos-6-10.sh", env: {
    "VM_CONFIG_PATH"      => "#{VM.vm_path[:guest]}/centos-6-10/config",
    "GUEST_SYNCED_FOLDER" => VM.synced_folder[:guest],
    "FORWARDED_PORT_80"   => VM.forwarded_ports.find{|port| port[:guest] == 80}[:host]
  }
end
