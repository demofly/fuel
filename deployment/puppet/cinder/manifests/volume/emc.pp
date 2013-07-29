# 
# A help doc and the driver from EMC: http://github.com/xing-yang/emc-openstack-cinder
# 
# A full sample of a usage:
#
# node /.../ {
#   class { 'cinder::volume::emc':
#     cinder_emc_config_file_path => '/etc/cinder/cinder_emc_config.xml',
#     cinder_emc_config_file_template => 'cinder/cinder_emc_config.xml.erb',
#     iscsi_target_prefix  => "iqn.2001-07.com.vnx",
#     iscsi_ip_address     => '7.7.7.7',
#     xml_storage_type     => 'super_storage',
#     xml_ecom_server_ip   => '2.2.2.2',
#     xml_ecom_server_port => '22222',
#     xml_masking_view     => 'openstack',
#     xml_user_name        => 'storage_admin',
#     xml_user_password    => 'storage_password',
#     cinder_emc_opts_hash => {
#       'EMC/my_option1' => { 'value' => 'my_text1' },
#       'EMC/my_option2' => { 'value' => 'my_text2' },
#     },
#   }
# }

class cinder::volume::emc (
  $cinder_emc_config_file_path = '/etc/cinder/cinder_emc_config.xml',
  $cinder_emc_config_file_template  = 'cinder/cinder_emc_config.xml.erb',
  $iscsi_target_prefix  = "iqn.2001-07.com.vnx",
  $iscsi_ip_address     = '',
  $xml_storage_type     = '',
  $xml_ecom_server_ip   = '',
  $xml_ecom_server_port = '',
  $xml_masking_view     = '', # may be 'openstack', is only needed for VMAX/VMAXe arrays.
  $xml_user_name        = '',
  $xml_user_password    = '',
  $cinder_emc_opts_hash = {},
) {

#  include cinder::params

  if empty($iscsi_ip_address) {
    fail('$iscsi_ip_address is not defined in cinder::volume::emc')
  }
  if empty($xml_ecom_server_ip) {
    fail('$xml_ecom_server_ip is not defined in cinder::volume::emc')
  }
  if empty($xml_ecom_server_port) {
    fail('$xml_xml_ecom_server_port is not defined in cinder::volume::emc')
  }
  if empty($xml_user_name) {
    fail('$xml_user_name is not defined in cinder::volume::emc')
  }

  $pkg_pywbem = $::osfamily ? {
    'Debian' => 'python-pywbem',
    default => 'pywbem'
  }
  
  package { $pkg_pywbem:
    ensure => present,
  } ->
  file { $cinder_emc_config_file_path:
    ensure => present,
    content => template( $cinder_emc_config_file_template ),
    mode => 644,
    owner => 'root',
    group => 'root',
  } ->
  cinder_config {
    'DEFAULT/enabled_backends':    value => 'EMC';
    'EMC/volume_driver':       value => 'cinder.volume.emc.EMCISCSIDriver';
    'EMC/iscsi_target_prefix': value => $iscsi_target_prefix;
    'EMC/iscsi_ip_address':    value => $iscsi_ip_address;
    'EMC/cinder_emc_config_file_path': value => $cinder_emc_config_file_path;
  }

  create_resources( 'cinder_config', $cinder_emc_opts_hash )

  if defined(Class['::openstack::cinder']) {
    Class['openstack::cinder'] -> Class['cinder::volume::emc']
  }
}
