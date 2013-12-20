class zarafa::server (
  $ensure         = hiera("${module_name}::server::ensure",running),
  $enable         = hiera("${module_name}::server::enable",true),
  $serverhostname = hiera("${module_name}::server::hostname",$::fqdn),
  $sslcafile      = hiera("${module_name}::server::sslkeyfile","/etc/pki/tls/certs/ca.crt"),
  $sslkeyfile     = hiera("${module_name}::server::sslkeyfile","/etc/pki/tls/certs/${::fqdn}.crt"),
  $mysqluser      = hiera("${module_name}::server::mysqluser",'zarafa'),
  $mysqlpassword  = hiera("${module_name}::server::mysqlpassword"),
  $mysqldb        = hiera("${module_name}::server::mysqlmysqldb",'zarafa'),
  $mysqlhost      = hiera("${module_name}::server::mysqlhost",'localhost'),
  $packages       = hiera("${module_name}::server::packages",'zarafa-server'),
  $options        = hiera_hash("${module_name}::server::options",{}),
  $configfile     = hiera("${module_name}::server::configfile",'/etc/zarafa/server.cfg')
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
  create_resources('zarafa::option',merge($server_options,$options), { file => $configfile, require => Package[$packages] })

  service { 'zarafa-server':
    ensure => $ensure,
    enable => $enable,
    require => Package[$packages]
  }
}
