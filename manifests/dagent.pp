class zarafa::dagent (
  $ensure         = hiera("${module_name}::dagent::ensure",running),
  $enable         = hiera("${module_name}::dagent::enable",true),
  $serverhostname = hiera("${module_name}::dagent::serverhostname",'localhost'),
  $packages       = hiera("${module_name}::dagent::packages",'zarafa-dagent'),
  $sslkeyfile     = hiera("${module_name}::dagent::sslkeyfile","/etc/zarafa/ssl/${::fqdn}.crt"),
  $options        = hiera_hash("${module_name}::dagent::options",{}),
  $configfile     = hiera("${module_name}::dagent::configfile",'/etc/zarafa/dagent.cfg')
) {
  package { $packages:
    ensure => present
  }

  $dagent_options = { 'server_socket-dagent' => { option => 'server_socket',
                                                  value => "https://${serverhostname}:237/zarafa"
                     },
                     'sslkey_file-dagent'    => { option => 'sslkey_file',
                                                  value  => $sslkeyfile
                     }
  }

  create_resources('zarafa::option',merge($dagent_options,$options), { file    => $configfile, 
                                                                       require => Package[$packages],
                                                                       notify  => Service['zarafa-dagent']
                                                                     })

  service { 'zarafa-dagent':
    ensure  => $ensure,
    enable  => $enable,
    require => Package[$packages]
  }
}
