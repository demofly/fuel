# $volume_name_template = volume-%s
#
# must be used via openstack::cinder only
#
#   class { 'cinder::volume':
#     multibackend => { 
#       'EMC_VNX_7500_North' => {
#         volume_driver        => 'cinder.volume.emc.EMCISCSIDriver',
#         cinder_emc_config_file_template => 'cinder/cinder_emc_config.xml.erb',
#         iscsi_target_prefix  => "iqn.2001-07.com.vnx",
#         iscsi_ip_address     => '7.7.7.7',
#         xml_storage_type     => 'super_storage',
#         xml_ecom_server_ip   => '2.2.2.2',
#         xml_ecom_server_port => '22222',
#         xml_masking_view     => 'openstack1',
#         xml_user_name        => 'storage_admin',
#         xml_user_password    => 'storage_password',
#       },
#       'EMC_VNX_7500_South' => {
#         volume_driver        => 'cinder.volume.emc.EMCISCSIDriver',
#         iscsi_target_prefix  => "iqn.2001-07.com.vnx",
#         iscsi_ip_address     => '7.7.7.8',
#         xml_storage_type     => 'super_storage',
#         xml_ecom_server_ip   => '2.2.2.3',
#         xml_ecom_server_port => '22222',
#         xml_masking_view     => 'openstack2',
#         xml_user_name        => 'storage_admin',
#         xml_user_password    => 'storage_password',
#       }
#     }
#   }

class cinder::volume (
  $package_ensure = 'latest',
  $enabled        = true,
  $multibackend   = {},
) {

  include cinder::params

  if ($::cinder::params::volume_package) { 
    $volume_package = $::cinder::params::volume_package
    Package['cinder'] -> Package[$volume_package]

    package { 'cinder-volume':
      name   => $volume_package,
      ensure => $package_ensure,
    }
  } else {
    $volume_package = $::cinder::params::package_name
  }
  
  case $::osfamily {
    "Debian":  {
      File[$::cinder::params::cinder_conf] -> Cinder_config<||>
      File[$::cinder::params::cinder_paste_api_ini] -> Cinder_api_paste_ini<||>
      Cinder_config <| |> -> Package['cinder-volume']
      Cinder_api_paste_ini<||> -> Package['cinder-volume']
    }
    "RedHat": {
      Package[$volume_package] -> Cinder_api_paste_ini<||>
      Package[$volume_package] -> Cinder_config<||>
    }
  }
  Cinder_config<||> ~> Service['cinder-volume']
  Cinder_config<||> ~> Exec['cinder-manage db_sync']
  Cinder_api_paste_ini<||> ~> Service['cinder-volume']

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'cinder-volume':
    name      => $::cinder::params::volume_service,
    enable    => $enabled,
    ensure    => $ensure,
    require   => Package[$volume_package],
    subscribe => File[$::cinder::params::cinder_conf],
  }

  # A multibacked feature implementation is below:

  $cinder_backends = keys( $multibackend )

  if !empty( $cinder_backends ) {
    cinder_config { 'DEFAULT/enabled_backends':
      value => join( $cinder_backends, ',' )
    }
  }

  define cinder_backend {
    $backend_options = $multibackend[ $title ]

    case $backend_options[ 'volume_driver' ] {
      default: {
      }

      'cinder.volume.emc.EMCISCSIDriver': {
        cinder::volume::emc { $title: backend_options => $backend_options }
      }

#     The sample below to understand how to add a support of backends with a different driver:
#     'cinder_YET_another_Driver': {
#       cinder::volume::YET_another_Driver { $title: backend_options => $backend_options }
#     }

    }
  }

  cinder_backend { $cinder_backends: }

}
