class zarafa::spooler (
  $ensure         = hiera("${module_name}::spooler::ensure",running),
  $enable         = hiera("${module_name}::spooler::enable",true),
  $packages       = hiera("${module_name}::spooler::packages",'zarafa-spooler'),
  $serverhostname = hiera("${module_name}::spooler::serverhostname",'localhost'),
  $sslkeyfile     = hiera("${module_name}::spooler::sslkeyfile","/etc/zarafa/ssl/${::fqdn}.crt"),
  $options        = hiera_hash("${module_name}::spooler::options",{}),
  $configfile     = hiera("${module_name}::spooler::configfile",'/etc/zarafa/spooler.cfg')
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
