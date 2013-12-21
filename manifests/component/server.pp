class zarafa::component::server (
  $ensure         = hiera("${module_name}::component::server::ensure",running),
  $enable         = hiera("${module_name}::component::server::enable",true),
  $serverhostname = hiera("${module_name}::component::server::hostname",$::fqdn),
  $sslcafile      = hiera("${module_name}::component::server::sslcakeyfile","/etc/zarafa/ssl/ca.crt"),
  $sslkeyfile     = hiera("${module_name}::component::server::sslkeyfile","/etc/zarafa/ssl/${::fqdn}.crt"),
  $sslkeysdir     = hiera("${module_name}::component::server::sslkeysdir","/etc/zarafa/sslkeys"),
  $mysqluser      = hiera("${module_name}::component::server::mysqluser",'zarafa'),
  $mysqlpassword  = hiera("${module_name}::component::server::mysqlpassword"),
  $mysqldb        = hiera("${module_name}::component::server::mysqlmysqldb",'zarafa'),
  $mysqlhost      = hiera("${module_name}::component::server::mysqlhost",'localhost'),
  $packages       = hiera("${module_name}::component::server::packages",'zarafa-server'),
  $options        = hiera_hash("${module_name}::component::server::options",{}),
  $configfile     = hiera("${module_name}::component::server::configfile",'/etc/zarafa/server.cfg')
) {

  package { $packages:
    ensure => present
  }

  $server_options = { 'server_hostname' => {
                        value => $serverhostname
                      },
                      'server_ssl_enabled' => {
                        value => 'yes'
                      },
                      'server_ssl_key_file' => {
                        value => $sslkeyfile
                      },
                      'server_ssl_ca_file' => {
                        value => $sslcafile
                      },
                      'sslkeys_path' => {
                        value => $sslkeysdir
                      },
                      'mysql_host'     => {
                        value => $mysqlhost
                      },
                      'mysql_database'     => {
                         value => $mysqldb
                      },
                      'mysql_user'     => {
                        value => $mysqluser
                      },
                      'mysql_password' => {
                        value => $mysqlpassword
                      },
                    }
  create_resources('zarafa::option',merge($server_options,$options), { file    => $configfile,
                                                                       require => Package[$packages],
                                                                       notify  => Service['zarafa-server']
                                                                     })

  service { 'zarafa-server':
    ensure => $ensure,
    enable => $enable,
    require => Package[$packages]
  }
}
