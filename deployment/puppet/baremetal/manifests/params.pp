# these parameters need to be accessed from several locations and
# should be considered to be constant
class baremetal::params {

  case $::osfamily {
    'RedHat': {
      $db_sync_command   = 'nova-baremetal-manage db sync'
    }
    'Debian': {
      $db_sync_command   = 'nova-baremetal-manage db sync'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat and Debian")
    }
  }

}
