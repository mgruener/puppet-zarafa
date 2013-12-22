class zarafa::component::server (
  $sslpubkeydir   = hiera("${module_name}::sslpubkeydir","/etc/zarafa/sslkeys"),
  $sslcertdir     = hiera("${module_name}::sslcertdir","/etc/zarafa/ssl"),
  $ensure         = hiera("${module_name}::component::server::ensure",running),
  $enable         = hiera("${module_name}::component::server::enable",true),
  $serverhostname = hiera("${module_name}::component::server::hostname",$::fqdn),
  $sslcafile      = hiera("${module_name}::component::server::sslcakeyfile","ca.crt"),
  $sslkeyfile     = hiera("${module_name}::component::server::sslkeyfile","${::fqdn}.crt"),
  $mysqluser      = hiera("${module_name}::dbhost::mysqluser",'zarafa'),
  $mysqlpassword  = hiera("${module_name}::dbhost::mysqlpassword"),
  $mysqldb        = hiera("${module_name}::dbhost::mysqldb",'zarafa'),
  $mysqlhost      = hiera("${module_name}::dbhost::mysqlhost",'localhost'),
  $packages       = hiera("${module_name}::component::server::packages",'zarafa-server'),
  $options        = hiera_hash("${module_name}::component::server::options",{}),
  $configfile     = hiera("${module_name}::component::server::configfile",'/etc/zarafa/server.cfg')
) {

  include zarafa::augeas

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
                        value => "${sslcertdir}/${sslkeyfile}"
                      },
                      'server_ssl_ca_file' => {
                        value => "${sslcertdir}/${sslcafile}"
                      },
                      'sslkeys_path' => {
                        value => $sslpubkeydir
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
