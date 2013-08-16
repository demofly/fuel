class baremetal (
  $package_ensure = 'present',

  $scheduler_host_manager   = 'nova.scheduler.baremetal_host_manager.BaremetalHostManager',
  $firewall_driver          = 'nova.virt.firewall.NoopFirewallDriver',
  $compute_driver           = 'nova.virt.baremetal.driver.BareMetalDriver',
  $ram_allocation_ratio     = '1.0',
  $reserved_host_memory_mb  = '0',

  $python_path = $osfamily ? {
    'Debian' => 'python2.7/dist-packages',
    default  => 'python2.6/site-packages'
  },
  $baremetal_net_config_template        = "/usr/lib/$python_path/nova/virt/baremetal/net-static.ubuntu.template", # TODO: OS dependent path
  $baremetal_tftp_root                  = '/tftpboot',
  $baremetal_power_manager              = 'nova.virt.baremetal.ipmi.IPMI',
  $baremetal_driver                     = 'nova.virt.baremetal.pxe.PXE',
  $baremetal_instance_type_extra_specs  = 'cpu_arch:x86_64',
  $baremetal_sql_connection             = "mysql://nova:nova@${service_endpoint}/nova_bm",

  $baremetal_dnsmasq_bind_iface         = 'eth0.baremetalvlan',
) {

  include baremetal::params

  if !defined( Package['ipmitool'] ) {
    package { 'ipmitool': ensure => present }
  }
  if !defined( Package['syslinux'] ) {
    package { 'syslinux': ensure => present }
  }

  # Episode 1: dnsmasq & tftp

  if !defined( Package['dnsmasq'] ) {
    package { 'dnsmasq':  ensure => present }
  }

  File['/tftpboot'] -> File['/tftpboot/pxelinux.cfg']

  File['/var/lib/nova/baremetal'] -> File[
      '/var/lib/nova/baremetal/dnsmasq',
      '/var/lib/nova/baremetal/console'
  ]

  file {
    [
      '/tftpboot',
      '/tftpboot/pxelinux.cfg',
      '/var/lib/nova/baremetal',
      '/var/lib/nova/baremetal/dnsmasq',
      '/var/lib/nova/baremetal/console',
    ]:
      ensure => directory,
      owner => nova,
      mode => 755;

    [
      '/etc/dnsmasq.conf',
      '/etc/init.d/dnsmasq',
    ]:
      ensure => absent;

    '/etc/dnsmasq-bm.conf':
      content => template('baremetal/dnsmasq-bm.conf.erb'), # TODO: $baremetal_dnsmasq_bind_iface
      mode => 644,
      owner => root;

    '/etc/init.d/fuel-dnsmasq-bm':
      source => 'puppet:///modules/baremetal/fuel-dnsmasq-bm',
      mode => 755,
      owner => root;

    '/etc/init.d/fuel-nova-baremetal-deploy-helper':
      source => 'puppet:///modules/baremetal/fuel-nova-baremetal-deploy-helper',
      mode => 755,
      owner => root;

    '/tftpboot/pxelinux.0':
      source => '/usr/share/syslinux/pxelinux.0', # Note: CentOS only
      require => [
        File['/tftpboot'],
        Package['syslinux'],
      ],
      mode => 644,
      owner => root;
  }

  service {
    'fuel-dnsmasq-bm':
      ensure => running,
      enable => true,
      hasstatus => true,
      hasrestart => true,
      restart => '/etc/init.d/fuel-dnsmasq-bm status && /etc/init.d/fuel-dnsmasq-bm reload || /etc/init.d/fuel-dnsmasq-bm restart',
      require => [
        Package['dnsmasq'],
        File[
          '/etc/dnsmasq-bm.conf',
          '/etc/init.d/fuel-dnsmasq-bm'
        ]
      ],
      subscribe => [
        Package['dnsmasq'],
        File[
          '/etc/dnsmasq-bm.conf',
          '/etc/init.d/fuel-dnsmasq-bm'
        ]
      ];

    'fuel-nova-baremetal-deploy-helper':
      hasstatus => true,
      hasrestart => true,
      require => File['/etc/init.d/fuel-nova-baremetal-deploy-helper'];
  }

  # Episode 2: iptables

  # iptables:
  # iptables -I INPUT -p tcp -m multiport --ports 10000 -m comment --comment "nova-baremetal-deploy-helper" -j ACCEPT

  firewall {'401 nova-baremetal-deploy-helper':
    port => '10000',
    proto  => 'tcp',
    action => 'accept',
  }

  # Episode 3: nova.conf

  nova_config {
    'DEFAULT/scheduler_host_manager':       value => $scheduler_host_manager;
    'DEFAULT/firewall_driver':              value => $firewall_driver;
    'DEFAULT/compute_driver':               value => $compute_driver;
    'DEFAULT/ram_allocation_ratio':         value => $ram_allocation_ratio;
    'DEFAULT/reserved_host_memory_mb':      value => $reserved_host_memory_mb;

    'baremetal/net_config_template':        value => $baremetal_net_config_template;
    'baremetal/tftp_root':                  value => $baremetal_tftp_root;
    'baremetal/power_manager':              value => $baremetal_power_manager;
    'baremetal/driver':                     value => $baremetal_driver;
    'baremetal/instance_type_extra_specs':  value => $baremetal_instance_type_extra_specs;
    'baremetal/sql_connection':             value => $baremetal_sql_connection;
  }

  # Episode 4: patch for IPMI.py

  file { 'ipmi.py.patch':
    name => "/usr/lib/${python_path}/nova/virt/baremetal/ipmi.py.patch",
    source => 'puppet:///modules/baremetal/ipmi.py.patch',
    ensure => present,
  }

  if !defined( Package['patch'] ) {
    package { 'patch': ensure => present }
  }

  exec { 'patch-nova-ipmi':
    path    => ["/sbin", "/bin", "/usr/sbin", "/usr/bin"],
    command => "patch -p0 -f \
      /usr/lib/${python_path}/nova/virt/baremetal/ipmi.py \
      /usr/lib/${python_path}/nova/virt/baremetal/ipmi.py.patch",
    require => [
      File['ipmi.py.patch'],
      Package['patch', $::nova::params::compute_package_name]
    ],
    subscribe => [
      File['ipmi.py.patch'],
      Package[$::nova::params::compute_package_name]
    ],
    returns => [0, 1],
    refreshonly => true,
  }

  # Episode 5: MySQL DB

  # mysql DB: mysql> CREATE DATABASE nova_bm;
  # mysql> GRANT ALL ON nova_bm.* TO 'nova'@'%';
  # nova-baremetal-manage db sync
  #
  # This is done in openstack/.../mysql

  exec { $baremetal::params::db_sync_command:
    path        => '/usr/bin',
    refreshonly => true,
  }

  Nova_config <| |> ~>
    Exec[$baremetal::params::db_sync_command] ~>
      Service <| title == "$nova::params::compute_service_name" |>


  # Episode 6: incron

#  file {
#    '/etc/incron.d/root':
#      ensure => present,
#      content => '/tftpboot/pxelinux.cfg IN_CREATE,IN_DELETE /usr/bin/bm-manage-mac $# $%',
#      notify => Service['incron'];

#    '/usr/bin/bm-manage-mac':
#      source => 'puppet:///modules/baremetal/bm-manage-mac',
#      ensure => present;
#  }

#  if !defined( Package['incron'] ) {
#    package { 'incron': ensure => installed }
#  }

#  if !defined( Service['incron'] ) {
#    service { 'incron':
#      name => $osfamily ? {
#        'Debian' => 'incron',
#        default  => 'incrond',
#      },
#      ensure => running,
#      enable => true,
#      require => Package['incron'],
#    }
#  }


}
