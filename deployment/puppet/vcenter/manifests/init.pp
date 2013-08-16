#
# == Class: vcenter
#
# Manifest to install/configure nova-compute with vCenter Driver
#
# class { 'vcenter':
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



class vcenter (
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

  # vCenter part of the manifest

  package { ['python-suds', 'tomcat6']:
      ensure => present;
  }

  # Note: CentOS tested only
  service { 'tomcat6': 
    ensure => running,
    enable => true,
    hasstatus => true,
    require => Package['tomcat6'],
    subscribe => Package['tomcat6'],
  }

  if !defined( Package['unzip'] ) {
    package { 'unzip':
      ensure => present,
    }
  }

  # Note: the source file below must be dowloaded to /etc/puppet/modules/vcenter/files/vsphere-sdk.zip from http://www.vmware.com/support/developer/vc-sdk/ by pressing the 'Download' link at the top of the page.
  file { '/etc/nova/vsphere-sdk.zip':
    source => 'puppet:///modules/vcenter/vsphere-sdk.zip',
    ensure => present;
  }

  exec { 'Tomcat vSphere SDK installation':
    command => '/etc/init.d/tomcat6 stop;
      rm -rf /var/lib/tomcat6/webapps/vmware;
      mkdir -p /var/lib/tomcat6/webapps/vmware;
      cd /var/lib/tomcat6/webapps/vmware &&
      unzip /etc/nova/vsphere-sdk.zip',
    path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
    require => [ 
      Package['unzip'],
      File[ '/etc/nova/vsphere-sdk.zip' ]
    ],
    notify => Service['tomcat6'],
    subscribe => File[ '/etc/nova/vsphere-sdk.zip' ],
    refreshonly => true,
  }

  # vCenter options validation

  if !( $compute_driver in ['vmwareapi.VMwareVCDriver', 'vmwareapi.VMwareESXDriver'] ) {
    fail('$compute_driver is not suitable in ::vcenter class')
  }
  if empty($vmwareapi_server_ip) {
    fail('$vmwareapi_server_ip is not defined in ::vcenter')
  }
  if empty($vmwareapi_username) {
    fail('$vmwareapi_username is not defined in ::vcenter')
  }
  if ('vmwareapi.VMwareVCDriver' == $compute_driver) {
    if empty($vmwareapi_clustername) {
      fail('$vmwareapi_clustername is not defined in ::vcenter for vmwareapi.VMwareVCDriver')
    }
  }
  if empty($vmwareapi_wsdl_loc) {
    fail('$vmwareapi_wsdl_loc is not defined in ::vcenter')
  }
  if empty($vmwareapi_api_retry_count) {
    fail('$vmwareapi_api_retry_count is not defined in ::vcenter')
  }
  if empty($vmwareapi_task_poll_interval) {
    fail('$vmwareapi_task_poll_interval is not defined in ::vcenter')
  }
  if empty($vmwareapi_vlan_interface) {
    fail('$vmwareapi_vlan_interface is not defined in ::vcenter')
  }

  nova_config {
    'DEFAULT/compute_driver':               value => $compute_driver;
    'DEFAULT/vmwareapi_host_ip':            value => $vmwareapi_server_ip;
    'DEFAULT/vmwareapi_host_username':      value => $vmwareapi_username;
    'DEFAULT/vmwareapi_host_password':      value => $vmwareapi_password;
    'DEFAULT/vmwareapi_cluster_name':       value => $vmwareapi_clustername;
    'DEFAULT/vmwareapi_wsdl_loc':           value => $vmwareapi_wsdl_loc;
    'DEFAULT/integration_bridge':           value => $integration_bridge;
    'DEFAULT/use_linked_clone':             value => $use_linked_clone;
    'DEFAULT/vmwareapi_api_retry_count':    value => $vmwareapi_api_retry_count;
    'DEFAULT/vmwareapi_task_poll_interval': value => $vmwareapi_task_poll_interval;
    'DEFAULT/vmwareapi_vlan_interface':     value => $vmwareapi_vlan_interface;
  }

}
