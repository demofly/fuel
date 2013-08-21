#
# == Class: openstack::compute
#
# Manifest to install/configure nova-compute
#
# === Parameters
#
# See params.pp
#
# [private_interface] Interface used for vm networking connectivity. Required.
# [internal_address] Internal address used for management. Required.
# [public_interface] Public interface used to route public traffic. Optional.
#   Defaults to false.
# [fixed_range] Range of ipv4 network for vms.
# [network_manager] Nova network manager to use.
# [auto_assign_floating_ip] Rather configured to automatically allocate and
#   assign a floating IP address to virtual instances when they are launched.
#   Defaults to false.
# [multi_host] Rather node should support multi-host networking mode for HA.
#   Optional. Defaults to false.
# [network_config] Hash that can be used to pass implementation specifc
#   network settings. Optioal. Defaults to {}
# [sql_connection] SQL connection information. Optional. Defaults to false
#   which indicates that exported resources will be used to determine connection
#   information.
# [nova_user_password] Nova service password.
#  [rabbit_nodes] RabbitMQ nodes or false. Optional. Defaults to false.
#  [rabbit_password] RabbitMQ password. Optional. Defaults to  'rabbit_pw',
#  [rabbit_user] RabbitMQ user. Optional. Defaults to 'nova',
#  [glance_api_servers] List of glance api servers of the form HOST:PORT
#    delimited by ':'. False indicates that the resource should be collected.
#    Optional. Defaults to false,
#  [libvirt_type] Underlying libvirt supported hypervisor.
#    Optional. Defaults to 'kvm',
#  [vncproxy_host] Host that serves as vnc proxy. Optional.
#    Defaults to false. False indicates that a vnc proxy should not be configured.
#  [vnc_enabled] Rather vnc console should be enabled.
#    Optional. Defaults to 'true',
# [verbose] Rather to print more verbose (INFO+) output. If non verbose and non debug, would give syslog_log_level (default is WARNING) output. Optional. Defaults to false.
# [debug] Rather to print even more verbose (DEBUG+) output. If true, would ignore verbose option. Optional. Defaults to false.
#  [manage_volumes] Rather nova-volume should be enabled on this compute node.
#    Optional. Defaults to false.
#  [nova_volumes] Name of volume group in which nova-volume will create logical volumes.
#    Optional. Defaults to nova-volumes.
# [use_syslog] Rather or not service should log to syslog. Optional.
# [syslog_log_facility] Facility for syslog, if used. Optional. Note: duplicating conf option 
#       wouldn't have been used, but more powerfull rsyslog features managed via conf template instead
# [syslog_log_level] logging level for non verbose and non debug mode. Optional.
#
# class { 'openstack::nova::compute':
#   internal_address   => '192.168.2.2',
#   vncproxy_host      => '192.168.1.1',
#   nova_user_password => 'changeme',
# }
#
# class { 'openstack::nova::compute_vcenter':
#   internal_address   => '192.168.2.2',
#   vncproxy_host      => '192.168.1.1',
#   nova_user_password => 'changeme',
#
#   compute_driver               = 'vmwareapi.VMwareVCDriver',
#   vmwareapi_server_ip          = '',
#   vmwareapi_username           = '',
#   vmwareapi_password           = '',
#   vmwareapi_clustername        = '',
#   vmwareapi_wsdl_loc           = 'http://127.0.0.1:8080/vmware/SDK/vsphere-ws/wsdl/vim25/vimService.wsdl',
#   integration_bridge           = 'br-int',
#   use_linked_clone             = 'true',
#   vmwareapi_api_retry_count    = '10',
#   vmwareapi_task_poll_interval = '5.0',
#   vmwareapi_vlan_interface     = 'vmnic0',
# }
#
# How to use:
#
# 1. Make a duplicate of a compute node definition inside site.pp.
# 2. Rename it: node /fuel-vcenter-[\d+]/ {, rename the class of 'openstack::compute' to 'openstack::compute_vcenter'
# 3. Expand the class option list in site.pp as shown before this HowTo with options you want to redefine (the options above are shown with defaults)
# 3. Use fuel-vcenter-01.* names for your vcenter integration nodes
# 4. Set "role: vcenter" in config.yaml
# 5. If you skipped p.4, use the next update of $nodes array:
#  $nodes = [ ... {
#    "internal_address" => "10.0.0.121",
#    "public_address" => "10.8.8.121",
#    "name" => "fuel-vcenter-01",
#    "role" => "vcenter"
#  } ... ]

class openstack::compute_vcenter (
  # Required Network
  $internal_address,
  # Required Nova
  $nova_user_password,
  # Network
  # DB
  $sql_connection                = false,
  # Nova
  $purge_nova_config             = false,
  # Rabbit
  $rabbit_nodes                  = false,
  $rabbit_password               = 'rabbit_pw',
  $rabbit_host                   = false,
  $rabbit_user                   = 'nova',
  $rabbit_ha_virtual_ip          = false,
  # Glance
  $glance_api_servers            = undef,
  # Virtualization
  $libvirt_type                  = 'kvm',
  # VNC
  $vnc_enabled                   = true,
  $vncproxy_host                 = undef,
  # General
  $enabled                       = true,
  $multi_host                    = false,
  $auto_assign_floating_ip       = false,
  $network_config                = {},
  $public_interface,
  $private_interface,
  $network_manager,
  $fixed_range                   = undef,
  # Quantum
  $quantum                       = false,
  $quantum_sql_connection        = false,
  $quantum_host                  = false,
  $quantum_user_password         = false,
  $tenant_network_type           = 'gre',
  $segment_range                 = '1:4094',
  # nova compute configuration parameters
  $verbose                       = false,
  $debug               = false,
  $service_endpoint              = '127.0.0.1',
  $ssh_private_key               = undef,
  $cache_server_ip               = ['127.0.0.1'],
  $cache_server_port             = '11211',
  $ssh_public_key                = undef,
  # if the cinder management components should be installed
  $manage_volumes                = false,
  $nv_physical_volume            = undef,
  $cinder_volume_group           = 'cinder-volumes',
  $cinder                        = true,
  $cinder_user_password          = 'cinder_user_pass',
  $cinder_db_password            = 'cinder_db_pass',
  $cinder_db_user                = 'cinder',
  $cinder_db_dbname              = 'cinder',
  $cinder_iscsi_bind_addr        = false,
  $cinder_multibackend           = {},
  
  $db_host                       = '127.0.0.1',
  $use_syslog                    = false,
  $syslog_log_facility           = 'LOCAL6',
  $syslog_log_facility_cinder    = 'LOCAL3',
  $syslog_log_facility_quantum   = 'LOCAL4',
  $syslog_log_level = 'WARNING',
  $nova_rate_limits              = undef,
  $cinder_rate_limits            = undef,
  $create_networks               = false,

  # vCenter integration variables

  $compute_driver               = 'vmwareapi.VMwareVCDriver',
  $vmwareapi_server_ip          = '',
  $vmwareapi_username           = '',
  $vmwareapi_password           = '',
  $vmwareapi_clustername        = '',
  $vmwareapi_wsdl_loc           = 'http://127.0.0.1:8080/vmware/SDK/vsphere-ws/wsdl/vim25/vimService.wsdl',
  $integration_bridge           = 'br-int',
  $use_linked_clone             = 'true',
  $vmwareapi_api_retry_count    = '10',
  $vmwareapi_task_poll_interval = '5.0',
  $vmwareapi_vlan_interface     = 'vmnic0',

) {

  #
  # indicates that all nova config entries that we did
  # not specifify in Puppet should be purged from file
  #
  if ! defined( Resources[nova_config] ) {
    if ($purge_nova_config) {
      resources { 'nova_config':
        purge => true,
      }
    }
  }

  $final_sql_connection = $sql_connection
  $glance_connection = $glance_api_servers
  $rabbit_connection = $rabbit_host

  $memcached_addresses =  inline_template("<%= @cache_server_ip.collect {|ip| ip + ':' + @cache_server_port }.join ',' %>")
  nova_config {'DEFAULT/memcached_servers':
    value => $memcached_addresses
  }

  class { 'nova':
      ensure_package       => $::openstack_version['nova'],
      sql_connection       => $sql_connection,
      rabbit_nodes         => $rabbit_nodes,
      rabbit_userid        => $rabbit_user,
      rabbit_password      => $rabbit_password,
      image_service        => 'nova.image.glance.GlanceImageService',
      glance_api_servers   => $glance_api_servers,
      verbose              => $verbose,
      debug                => $debug,
      rabbit_host          => $rabbit_host,
      use_syslog           => $use_syslog,
      syslog_log_facility  => $syslog_log_facility,
      syslog_log_level     => $syslog_log_level,
      api_bind_address     => $internal_address,
      rabbit_ha_virtual_ip => $rabbit_ha_virtual_ip,
      state_path           => $state_path,
  }

  #Cinder setup
    $enabled_apis = 'metadata'
    package {'python-cinderclient': ensure => present}
    if $cinder and $manage_volumes {
      class {'openstack::cinder':
        sql_connection       => "mysql://${cinder_db_user}:${cinder_db_password}@${db_host}/${cinder_db_dbname}?charset=utf8",
        rabbit_password      => $rabbit_password,
        rabbit_host          => false,
        rabbit_nodes         => $rabbit_nodes,
        volume_group         => $cinder_volume_group,
        physical_volume      => $nv_physical_volume,
        manage_volumes       => $manage_volumes,
        enabled              => true,
        glance_api_servers   => $glance_api_servers,
        auth_host            => $service_endpoint,
        bind_host            => false,
        iscsi_bind_host      => $cinder_iscsi_bind_addr,
        cinder_user_password => $cinder_user_password,
        verbose              => $verbose,
        debug                => $debug,
        use_syslog           => $use_syslog,
        syslog_log_facility  => $syslog_log_facility_cinder,
        syslog_log_level     => $syslog_log_level,
        cinder_rate_limits   => $cinder_rate_limits,
        rabbit_ha_virtual_ip => $rabbit_ha_virtual_ip,
        multibackend         => $cinder_multibackend,
      }
    }



  # Install / configure nova-compute
  class { '::nova::compute':
    ensure_package                => $::openstack_version['nova'],
    enabled                       => $enabled,
    vnc_enabled                   => $vnc_enabled,
    vncserver_proxyclient_address => $internal_address,
    vncproxy_host                 => $vncproxy_host,
  }

    case $::osfamily {
      'Debian': {$scp_package='openssh-client'}
      'RedHat': {$scp_package='openssh-clients'}
       default: {
                 fail("Unsupported osfamily: ${osfamily}")
      }
    }
    if !defined(Package[$scp_package]) {
      package {$scp_package: ensure => present }
    }

  if ( $ssh_private_key != undef ) {
   file { '/var/lib/nova/.ssh':
      ensure => directory,
      owner  => 'nova',
      group  => 'nova',
      mode   => '0700'
    }
    file { '/var/lib/nova/.ssh/authorized_keys':
      ensure => present,
      owner  => 'nova',
      group  => 'nova',
      mode   => '0400',
      source => $ssh_public_key,
    }
    file { '/var/lib/nova/.ssh/id_rsa':
      ensure => present,
      owner  => 'nova',
      group  => 'nova',
      mode   => '0400',
      source => $ssh_private_key,
    }
    file { '/var/lib/nova/.ssh/id_rsa.pub':
      ensure => present,
      owner  => 'nova',
      group  => 'nova',
      mode   => '0400',
      source => $ssh_public_key,
    }
    file { '/var/lib/nova/.ssh/config':
      ensure  => present,
      owner   => 'nova',
      group   => 'nova',
      mode    => '0600',
      content => "Host *\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null\n",
    }
  }

  # configure nova api
  class { 'nova::api':
    ensure_package    => $::openstack_version['nova'],
    enabled           => true,
    admin_tenant_name => 'services',
    admin_user        => 'nova',
    admin_password    => $nova_user_password,
    enabled_apis      => $enabled_apis,
    cinder            => $cinder,
    auth_host         => $service_endpoint,
    nova_rate_limits  => $nova_rate_limits,
  }

  # if the compute node should be configured as a multi-host
  # compute installation
  if ! $quantum {
    if ! $fixed_range {
      fail('Must specify the fixed range when using nova-networks')
    }

    if $multi_host {
      include keystone::python

      nova_config {
        'DEFAULT/multi_host':      value => 'True';
        'DEFAULT/send_arp_for_ha': value => 'True';
        # 'DEFAULT/metadata_listen': value => $internal_address;
        'DEFAULT/metadata_host':   value => $internal_address;
      }

#      if ! $public_interface {
#        fail('public_interface must be defined for multi host compute nodes')
#      }

      $enable_network_service = true

      if $auto_assign_floating_ip {
         nova_config { 'DEFAULT/auto_assign_floating_ip': value => 'True' }
      }


    } else {
      $enable_network_service = false

      nova_config {
        'DEFAULT/multi_host':      value => 'False';
        'DEFAULT/send_arp_for_ha': value => 'False';
      }
    }

    class { 'nova::network':
      ensure_package    => $::openstack_version['nova'],
      private_interface => $private_interface,
      public_interface  => $public_interface,
      fixed_range       => $fixed_range,
      floating_range    => $floating_range,
      network_manager   => $network_manager,
      config_overrides  => $network_config,
      create_networks   => $create_networks,
      num_networks      => $num_networks,
      enabled           => $enable_network_service,
      install_service   => $enable_network_service,
    }
  } else {

    if ! $quantum_sql_connection {
      fail('quantum sql connection must be specified when quantum is installed on compute instances')
    }
    if ! $quantum_host {
      fail('quantum host must be specified when quantum is installed on compute instances')
    }
    if ! $quantum_user_password {
      fail('quantum user password must be set when quantum is configured')
    }

    $enable_tunneling = $tenant_network_type ? { 'gre' => true, 'vlan' => false }

    class { '::quantum':
      rabbit_host     => $rabbit_nodes ? { false => $rabbit_host, default => $rabbit_nodes },
      rabbit_user     => $rabbit_user,
      rabbit_password => $rabbit_password,
      verbose         => $verbose,
      debug           => $debug,
      use_syslog           => $use_syslog,
      syslog_log_level     => $syslog_log_level,
      syslog_log_facility  => $syslog_log_facility_quantum,
      rabbit_ha_virtual_ip => $rabbit_ha_virtual_ip,
      auth_host            => $auth_host,
      auth_tenant          => 'services',
      auth_user            => 'quantum',
      auth_password        => $quantum_user_password,
    }

    class { 'quantum::plugins::ovs':
      sql_connection      => $quantum_sql_connection,
      tenant_network_type => $tenant_network_type,
      enable_tunneling    => $enable_tunneling,
      bridge_mappings     => ['physnet2:br-prv'],
      network_vlan_ranges => "physnet1,physnet2:${segment_range}",
      tunnel_id_ranges    => "${segment_range}",
    }

    class { 'quantum::agents::ovs':
      bridge_uplinks   => ["br-prv:${private_interface}"],
      bridge_mappings  => ['physnet2:br-prv'],
      enable_tunneling => $enable_tunneling,
      local_ip         => $internal_address,
    }


    # class { 'quantum::agents::dhcp':
    #   debug          => True,
    #   use_namespaces => $::quantum_use_namespaces,
    # }

    # class { 'quantum::agents::l3':
    #   debug          => True,
    #   auth_url       => "http://${service_endpoint}:35357/v2.0",
    #   auth_tenant    => 'services',
    #   auth_user      => 'quantum',
    #   auth_password  => $quantum_user_password,
    #   use_namespaces => $::quantum_use_namespaces,
    # }

    class { 'nova::compute::quantum': }

    # does this have to be installed on the compute node?
    # NOTE
    class { 'nova::network::quantum':
    #$fixed_range,
      quantum_admin_password    => $quantum_user_password,
    #$use_dhcp                  = 'True',
    #$public_interface          = undef,
      quantum_connection_host   => $quantum_host,
      quantum_auth_strategy     => 'keystone',
      quantum_url               => "http://${service_endpoint}:9696",
      quantum_admin_tenant_name => 'services',
      quantum_admin_username    => 'quantum',
      quantum_admin_auth_url    => "http://${service_endpoint}:35357/v2.0",
      public_interface          => $public_interface,
    }

    nova_config {
      'linuxnet_interface_driver':       value => 'nova.network.linux_net.LinuxOVSInterfaceDriver';
      'linuxnet_ovs_integration_bridge': value => 'br-int';
    }
  }

  # vCenter part of the manifest

  class { 'vcenter':
    compute_driver                => $compute_driver,
    vmwareapi_server_ip           => $vmwareapi_server_ip,
    vmwareapi_username            => $vmwareapi_username,
    vmwareapi_password            => $vmwareapi_password,
    vmwareapi_clustername         => $vmwareapi_clustername,
    vmwareapi_wsdl_loc            => $vmwareapi_wsdl_loc,
    integration_bridge            => $integration_bridge,
    use_linked_clone              => $use_linked_clone,
    vmwareapi_api_retry_count     => $vmwareapi_api_retry_count,
    vmwareapi_task_poll_interval  => $vmwareapi_task_poll_interval,
    vmwareapi_vlan_interface      => $vmwareapi_vlan_interface,
  }
}
