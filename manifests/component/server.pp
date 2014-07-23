class zarafa::component::server (
  $sslpubkeydir   = "/etc/zarafa/sslkeys",
  $sslcertdir     = "/etc/zarafa/ssl",
  $ensure         = running,
  $enable         = true,
  $serverhostname = $::fqdn,
  $sslcafile      = "ca.crt",
  $sslkeyfile     = "${::fqdn}.crt",
  $mysqluser      = 'zarafa',
  $mysqlpassword  = '',
  $mysqldb        = 'zarafa',
  $mysqlhost      = 'localhost',
  $packages       = 'zarafa-server',
  $options        = {},
  $configfile     = '/etc/zarafa/server.cfg'
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  @@mysql::db { $mysqldb:
    user     => $mysqluser,
    password => $mysqlpassword,
    host     => $::fqdn,
    tag      => 'zarafa_db',
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
