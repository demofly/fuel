# 
# A help doc and the driver from EMC: http://github.com/xing-yang/emc-openstack-cinder
# 
# A sample of a usage:
# [ should be called from cinder::volume class only ]
#
#   cinder::volume::emc { 'EMC_VNX_7500':
#     backend_options => {
#       cinder_emc_config_file_template => 'cinder/cinder_emc_config.xml.erb',
#       iscsi_target_prefix  => "iqn.2001-07.com.vnx",
#       iscsi_ip_address     => '7.7.7.7',
#       xml_storage_type     => 'super_storage',
#       xml_ecom_server_ip   => '2.2.2.2',
#       xml_ecom_server_port => '22222',
#       xml_masking_view     => 'openstack',
#       xml_user_name        => 'storage_admin',
#       xml_user_password    => 'storage_password',
#     }
#   }

define cinder::volume::emc (
  $backend_options = {
    'cinder_emc_config_file_template'  => 'cinder/cinder_emc_config.xml.erb',
    'iscsi_target_prefix'  => "iqn.2001-07.com.vnx",
    'iscsi_ip_address'     => '',
    'xml_storage_type'     => '',
    'xml_ecom_server_ip'   => '',
    'xml_ecom_server_port' => '',
    'xml_masking_view'     => '', # may be 'openstack', is only needed for VMAX/VMAXe arrays.
    'xml_user_name'        => '',
    'xml_user_password'    => '',
  },
) {

#  include cinder::params

  $backend_name = $title
  $cinder_emc_config_file_path = "/etc/cinder/cinder_emc_config_${backend_name}.xml"

  # Loading defaults, if not defined in $backend_options:

  $cinder_emc_config_file_template = empty( $backend_options[ 'cinder_emc_config_file_template' ] ) ? {
    true => 'cinder/cinder_emc_config.xml.erb',
    default => $backend_options[ 'cinder_emc_config_file_template' ]
  }
  $iscsi_target_prefix = empty( $backend_options[ 'iscsi_target_prefix' ] ) ? {
    true => 'iqn.2001-07.com.vnx',
    default => $backend_options[ 'iscsi_target_prefix' ]
  }
  $iscsi_ip_address = empty( $backend_options[ 'iscsi_ip_address' ] ) ? {
    true => '',
    default => $backend_options[ 'iscsi_ip_address' ]
  }
  $xml_storage_type = empty( $backend_options[ 'xml_storage_type' ] ) ? {
    true => '',
    default => $backend_options[ 'xml_storage_type' ]
  }
  $xml_ecom_server_ip = empty( $backend_options[ 'xml_ecom_server_ip' ] ) ? {
    true => '',
    default => $backend_options[ 'xml_ecom_server_ip' ]
  }
  $xml_ecom_server_port = empty( $backend_options[ 'xml_ecom_server_port' ] ) ? {
    true => '',
    default => $backend_options[ 'xml_ecom_server_port' ]
  }
  $xml_masking_view = empty( $backend_options[ 'xml_masking_view' ] ) ? {
    true => '',
    default => $backend_options[ 'xml_masking_view' ]
  }
  $xml_user_name = empty( $backend_options[ 'xml_user_name' ] ) ? {
    true => '',
    default => $backend_options[ 'xml_user_name' ]
  }
  $xml_user_password = empty( $backend_options[ 'xml_user_password' ] ) ? {
    true => '',
    default => $backend_options[ 'xml_user_password' ]
  }

  # Validate
  
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
  
  # Setup

  $pkg_pywbem = $::osfamily ? {
    'Debian' => 'python-pywbem',
    default => 'pywbem'
  }
  
  if !defined( Package[ $pkg_pywbem ] ) {
    package { $pkg_pywbem:
      ensure => present,
    }
  }
  
  file { $cinder_emc_config_file_path:
    ensure => present,
    content => template( $cinder_emc_config_file_template ),
    mode => 644,
    owner => 'root',
    group => 'root',
  } ->
  cinder_config {
    "${backend_name}/volume_driver":                value => 'cinder.volume.emc.EMCISCSIDriver';
    "${backend_name}/iscsi_target_prefix":          value => $iscsi_target_prefix;
    "${backend_name}/iscsi_ip_address":             value => $iscsi_ip_address;
    "${backend_name}/cinder_emc_config_file_path":  value => $cinder_emc_config_file_path;
  }
  
}
