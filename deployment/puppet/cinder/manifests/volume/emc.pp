class cinder::volume::emc (
  $iscsi_target_prefix = "iqn.2001-07.com.vnx",
  $iscsi_ip_address    = '192.168.255.255',
  $cinder_emc_config_file_path = '/etc/cinder/cinder_emc_config.xml',
  $cinder_emc_config_file_template  = 'cinder/cinder_emc_config.xml.erb',
  $cinder_emc_opts_hash = {},
) {

#  include cinder::params

  if empty($iscsi_ip_address) {
    fail('$iscsi_ip_address is not defined in cinder::volume::emc')
  }
  if empty($iscsi_target_prefix) {
    fail('$iscsi_target_prefix is not defined in cinder::volume::emc')
  }
  if empty($cinder_emc_config_file_path) {
    fail('$cinder_emc_config_file_path is not defined in cinder::volume::emc')
  }
  if empty($cinder_emc_config_file_template) {
    fail('$cinder_emc_config_file_template is not defined in cinder::volume::emc')
  }

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
     Class['cinder::volume::emc'] -> Class['openstack::cinder']
  }
}
