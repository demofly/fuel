# creates a real mount of real device
define swift::storage::hdd(
  $base_dir     = '/dev',
  $mnt_base_dir = '/srv/node',
  $byte_size    = '1024',
) {

  if(!defined(File[$base_dir])) {
    file { $base_dir:
      ensure => directory,
    }
  }

  if(!defined(File[$mnt_base_dir])) {
    file { $mnt_base_dir:
      owner  => 'swift',
      group  => 'swift',
      ensure => directory,
    }
  }

  exec { "create_partition-${name}":
    command     => "dd if=/dev/zero of=${base_dir}/${name} bs=${byte_size} count=1k bs=15k",
    path        => ['/usr/bin/', '/bin'],
    unless      => "bash -c \"(mount | grep ${base_dir}/${name})\"",
    require     => File[$base_dir],
  }

  swift::storage::xfs { $name:
    device       => "${base_dir}/${name}",
    mnt_base_dir => $mnt_base_dir,
    byte_size    => $byte_size,
    subscribe    => Exec["create_partition-${name}"],
    loopback     => false,
  }

}
