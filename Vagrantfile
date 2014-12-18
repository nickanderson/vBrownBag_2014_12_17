# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
RELEASE="3.6.3"
BUILD="1"

# Synced folders, if any, are stored here
synced_folders=Hash.new

# Extract SYNCED_FOLDERS into a hash for use below
if ENV['SYNCED_FOLDERS']
  ENV['SYNCED_FOLDERS'].split(/[,\s]+/).each do |pair|
    (src,dest) = pair.split(/:/)
    synced_folders[src] = dest
  end
end


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Dynamic Node Configuration
  # The number of client hosts to provision and bootstrap to the hub. Adjust this as desired.
  hosts = 4

  ##### No edits below this point are necessary #####

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "centos-6.5-x86_64-cfengine_enterprise-#{RELEASE}-#{BUILD}"
  config.vm.box_url = "http://cfengine.vagrant-baseboxes.s3.amazonaws.com/#{config.vm.box}.box"

  # Specify the first three octects of the private host_only network for inter
  # vm communication
  first_three_network_octets = "192.168.33"

  # We reserve the hub ip for .2
  cfengine_hub_ip = "#{first_three_network_octets}.2"

  # All the hosts get port 80 forwarded to this port + host_number
  # (just like the IP)
  prefix_80_fwd = 900

  # Begin Hub Configuration
  #

  hub_80_fwd = Integer("#{prefix_80_fwd}#{0+2}")

  config.vm.define :hub do |hub|
    hub.vm.hostname = "hub"
    hub.vm.network :private_network, ip: "#{cfengine_hub_ip}"
    hub.vm.network :forwarded_port, guest: 80, host: hub_80_fwd

    # Mount synced foleders (these are also mounted on clients below)
    synced_folders.each { |k, v|
      hub.vm.synced_folder k, v
    }
    if ENV['MASTERFILES']
      hub.vm.synced_folder ENV['MASTERFILES'], "/var/cfengine/masterfiles"
    else
      hub.vm.synced_folder "./masterfiles", "/var/cfengine/masterfiles"
    end


    hub.vm.provider "virtualbox" do |v|
        # v.gui = true
        v.customize ["modifyvm", :id, "--memory", "512", "--cpus", "2"]
        #v.name = "hub_#{package_version}_#{RELEASE}"
        v.name = "CFEngine Enterprise #{RELEASE}-#{BUILD} hub"
    end
    # Use a synced folder so that we can edit from outside of the environment
    # A typical workflow has masterfiles pulled from version control
    hub.vm.provision :shell, :path => "scripts/install_cfengine_enterprise.sh", :args => "hub"
    hub.vm.provision :shell, :path => "scripts/bootstrap_cfengine.sh", :args => "#{cfengine_hub_ip}"
    hub.vm.provision :shell, :path => "scripts/instructions.sh", :args => "localhost #{hub_80_fwd}"

  end

  #
  # Begin Dynamic Node Specification
  #

  # Calculate Node IP
  # .1 is reserved for internal router
  # .2 is reserved for the hub
  # .3 begins host ips
  host_ip_offset = 2
  #maxhosts = 252
  # Without a license there is no sense in going beyond 25 hosts.
  maxhosts = 25
  (1..hosts).each do |host_number|
    # Set padding for host name to make it look pretty
    host_name = "host" + host_number.to_s.rjust(3, '0')
    # Calculate ip address for host
    host_ip = "#{first_three_network_octets}.#{host_number+host_ip_offset}"
    # Calculate host port to forward to port 80
    host_80_fwd = Integer("#{prefix_80_fwd}#{host_number+host_ip_offset}")

    config.vm.define host_name.to_sym do |host|

      host.vm.hostname = "#{host_name}"
      host.vm.network :private_network, ip: "#{host_ip}"
      host.vm.network :forwarded_port, guest: 80, host: host_80_fwd

      # Mount synced foleders (these are also mounted on by the hub above)
      synced_folders.each { |k, v|
        config.vm.synced_folder k, v
      }

      host.vm.provision :shell, :path => "scripts/install_cfengine_enterprise.sh", :args => "agent"
      host.vm.provision :shell, :path => "scripts/bootstrap_cfengine.sh", :args => "#{cfengine_hub_ip}"
      host.vm.provision :shell, :path => "scripts/instructions.sh", :args => "localhost #{hub_80_fwd}"
      host.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", "128", "--cpus", "2"]
        #v.gui=true
        #v.name = "agent_#{host_name}_#{package_version}_#{RELEASE}"
        #v.name = "agent_#{host_name}"
        v.name = "CFEngine Enterprise #{RELEASE}-#{BUILD} agent #{host_name}"
      end

    end
  end
end
