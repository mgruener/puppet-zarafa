class zarafa::component::dagent (
  $serverhostname = hiera("${module_name}::component::server::hostname",'localhost'),
  $ensure         = hiera("${module_name}::component::dagent::ensure",running),
  $enable         = hiera("${module_name}::component::dagent::enable",true),
  $packages       = hiera("${module_name}::component::dagent::packages",'zarafa-dagent'),
  $sslkeyfile     = hiera("${module_name}::component::dagent::sslkeyfile","/etc/zarafa/ssl/${::fqdn}-dagent.crt"),
  $options        = hiera_hash("${module_name}::component::dagent::options",{}),
  $configfile     = hiera("${module_name}::component::dagent::configfile",'/etc/zarafa/dagent.cfg')
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

  $dagent_options = { 'server_socket-dagent' => { option => 'server_socket',
                                                  value => "https://${zarafaserver}:237/zarafa"
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
