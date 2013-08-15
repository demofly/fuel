#
# I should change this to mysql
# for consistency
#
class baremetal::db::mysql(
  $password,
  $dbname        = 'nova',
  $user          = 'nova',
  $host          = '127.0.0.1',
  $allowed_hosts = undef,
  $charset       = 'latin1',
  $cluster_id    = 'localzone',
  $db_sync_command   = 'nova-baremetal-manage db sync',
) {

  include baremetal::params

  Class['mysql::server']     -> Class['baremetal::db::mysql']
  Class['baremetal::db::mysql'] ~> Exec<| title == $db_sync_command |>
  Database[$dbname]          ~> Exec<| title == $db_sync_command |>

  require 'mysql::python'

  mysql::db { $dbname:
    user         => $user,
    password     => $password,
    host         => $host,
    charset      => $charset,
    # I may want to inject some sql
    require      => Class['mysql::server'],
  }

  if $allowed_hosts {
     # TODO this class should be in the mysql namespace
     baremetal::db::mysql::host_access { $allowed_hosts:
      user      => $user,
      password  => $password,
      database  => $dbname,
    }
  }
}
