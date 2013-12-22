class zarafa::component::spooler (
  $serverhostname = hiera("${module_name}::component::server::hostname",'localhost'),
  $ensure         = hiera("${module_name}::component::spooler::ensure",running),
  $enable         = hiera("${module_name}::component::spooler::enable",true),
  $packages       = hiera("${module_name}::component::spooler::packages",'zarafa-spooler'),
  $sslkeyfile     = hiera("${module_name}::component::spooler::sslkeyfile","/etc/zarafa/ssl/${::fqdn}-spooler.crt"),
  $options        = hiera_hash("${module_name}::component::spooler::options",{}),
  $configfile     = hiera("${module_name}::component::spooler::configfile",'/etc/zarafa/spooler.cfg')
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  if downcase($serverhostname) in downcase([ $::fqdn, $::hostname ]) {
    $zarafaserver = 'localhost'
  }
  else
    $zarafaserver = $serverhostname
  }

  $spooler_options = { 'server_socket-spooler' => { option => 'server_socket',
                                                    value  => "https://${zarafaserver}:237/zarafa"
                       },
                       'sslkey_file-spooler'   => { option => 'sslkey_file',
                                                    value  => $sslkeyfile
                       }
  }

  create_resources('zarafa::option',merge($spooler_options,$options), { file    => $configfile,
                                                                        require => Package[$packages],
                                                                        notify  => Service['zarafa-spooler']
                                                                      })

  service { 'zarafa-spooler':
    ensure => $ensure,
    enable => $enable,
    require => Package[$packages]
  }
}
