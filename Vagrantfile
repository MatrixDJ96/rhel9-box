# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Set right settings file
if Vagrant::Util::Platform.windows?
    settings_file = "settings.windows.yaml"
elsif Vagrant::Util::Platform.darwin?
    settings_file = "settings.darwin.yaml"
else
    settings_file = "settings.linux.yaml"
end

if !File.exist?(settings_file)
    settings_file = "settings.yaml"
end

settings = $settings ||= YAML.load_file(settings_file)

settings['first_provision'] ||= false

settings['synced_folder'] ||= {}
settings['synced_folder']['map'] = settings['synced_folder'].fetch('map', "").strip

settings['synced_folder']['opts'] ||= {}
settings['synced_folder']['opts']['type'] = settings['synced_folder'].delete('type')
settings['synced_folder']['opts'] = settings['synced_folder']['opts'].transform_keys(&:to_sym)

settings['forwarded_ports'] ||= {}
settings['forwarded_ports']['ftp'] ||= 2221
settings['forwarded_ports']['ssh'] ||= 2222
settings['forwarded_ports']['http'] ||= 80
settings['forwarded_ports']['https'] ||= 443
settings['forwarded_ports']['mysql'] ||= 3306

settings['vm'] ||= {}
settings['vm']['cpus'] ||= 2
settings['vm']['memory'] ||= 4096

settings['ssh'] ||= {}
settings['ssh']['insert_key'] = settings['ssh'].fetch('insert_key', false)
settings['ssh']['forward_agent'] = settings['ssh'].fetch('forward_agent', false)
settings['ssh']['private_key_path'] = settings['ssh'].fetch('private_key_path', "")

if settings['synced_folder']['map'].empty?
    abort 'Missing/wrong synced folder map configuration!'
end

Vagrant.configure("2") do |config|
    # Use RHEL 9 as base machine
    config.vm.box = "generic/rhel9"

    # Hostname
    config.vm.hostname = "vagrant.local"

    # Forwarded ports
    config.vm.network :forwarded_port, auto_correct: true, guest: 21, host: settings['forwarded_ports']['ftp']
    config.vm.network :forwarded_port, auto_correct: true, guest: 22, host: settings['forwarded_ports']['ssh'], id: "ssh"
    config.vm.network :forwarded_port, auto_correct: true, guest: 80, host: settings['forwarded_ports']['http']
    config.vm.network :forwarded_port, auto_correct: true, guest: 443, host: settings['forwarded_ports']['https']
    config.vm.network :forwarded_port, auto_correct: true, guest: 3306, host: settings['forwarded_ports']['mysql']

    # Private network
    config.vm.network :private_network, type: "dhcp"

    # Provision
    if !settings['first_provision']
        config.vm.provision :shell, path: "config/provision.sh"
    else
        config.vm.provision :shell, path: "config/provision/yum.sh"
    end

    # Virtualbox plugin
    if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false
    end

    # WinFSD plugin
    if Vagrant.has_plugin?("vagrant-winnfsd")
        config.winnfsd.uid = 1
        config.winnfsd.gid = 1
    end

    # Apache trigger
    if !settings['first_provision']
        config.trigger.after [:up, :reload] do |trigger|
            trigger.run_remote = { inline: "systemctl start httpd" }
        end
    end

    # Synced folders
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder settings['synced_folder']['map'], "/vagrant/projects", settings['synced_folder']['opts']

    if !settings['first_provision']
        config.vm.synced_folder "config", "/vagrant/config", create: true, owner: "root", group: "root"
        config.vm.synced_folder "documents", "/vagrant/documents", create: true, owner: "vagrant", group: "vagrant"
    end

    # VirtualBox settings
    config.vm.provider "virtualbox" do |vm|
        vm.cpus = settings['vm']['cpus']
        vm.memory = settings['vm']['memory']

        if !settings['vm']['gui'].nil?
            vm.gui = settings['vm']['gui']
        end
        if !settings['vm']['name'].empty?
            vm.name = settings['vm']['name']
        end
    end

    # VMWare settings
    config.vm.provider "vmware_desktop" do |vm|
        vm.cpus = settings['vm']['cpus']
        vm.memory = settings['vm']['memory']
        vm.linked_clone = false

        if !settings['vm']['gui'].nil?
            vm.gui = settings['vm']['gui']
        end
    end

    # libvirt settings
    config.vm.provider "libvirt" do |vm|
        vm.cpus = settings['vm']['cpus']
        vm.memory = settings['vm']['memory']
        vm.forward_ssh_port = true
    end

    # SSH settings
    config.ssh.insert_key = settings['ssh']['insert_key']
    config.ssh.forward_agent = settings['ssh']['forward_agent']

    if File.exist?(settings['ssh']['private_key_path'])
        config.ssh.private_key_path = settings['ssh']['private_key_path']
    end
end
