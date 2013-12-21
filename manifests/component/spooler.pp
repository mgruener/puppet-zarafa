class zarafa::component::spooler (
  $ensure         = hiera("${module_name}::component::spooler::ensure",running),
  $enable         = hiera("${module_name}::component::spooler::enable",true),
  $packages       = hiera("${module_name}::component::spooler::packages",'zarafa-spooler'),
  $serverhostname = hiera("${module_name}::component::spooler::serverhostname",'localhost'),
  $sslkeyfile     = hiera("${module_name}::component::spooler::sslkeyfile","/etc/zarafa/ssl/${::fqdn}-spooler.crt"),
  $options        = hiera_hash("${module_name}::component::spooler::options",{}),
  $configfile     = hiera("${module_name}::component::spooler::configfile",'/etc/zarafa/spooler.cfg')
) {
  package { $packages:
    ensure => present
  }

  $spooler_options = { 'server_socket-spooler' => { option => 'server_socket',
                                                    value  => "https://${serverhostname}:237/zarafa"
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
