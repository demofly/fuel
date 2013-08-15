#
# Used to grant access to the baremetal mysql DB
#
define baremetal::db::mysql::host_access ($user, $password, $database)  {
  if !defined( Database_user["${user}@${name}"] ) {
    database_user { "${user}@${name}":
      password_hash => mysql_password($password),
      provider => 'mysql',
      require => Database[$database],
    }
  }
  database_grant { "${user}@${name}/${database}":
    # TODO figure out which privileges to grant.
    privileges => "all",
    provider => 'mysql',
    require => Database_user["${user}@${name}"]
  }
}