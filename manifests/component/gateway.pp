class zarafa::component::gateway (
  $ensure         = hiera("${module_name}::component::gateway::ensure",running),
  $enable         = hiera("${module_name}::component::gateway::enable",true),
  $serverhostname = hiera("${module_name}::component::gateway::serverhostname",'localhost'),
  $packages       = hiera("${module_name}::component::gateway::packages",'zarafa-gateway'),
  $sslkeyfile     = hiera("${module_name}::component::gateway::sslkeyfile","/etc/zarafa/ssl/${::fqdn}-gateway.crt"),
  $options        = hiera_hash("${module_name}::component::gateway::options",{}),
  $configfile     = hiera("${module_name}::component::gateway::configfile",'/etc/zarafa/gateway.cfg')
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  $gateway_options = { 'server_socket-gateway' => { option => 'server_socket',
                                                    value => "https://${serverhostname}:237/zarafa"
                       },
                       'ssl_private_key_file-gateway'   => { option => 'ssl_private_key_file',
                                                             value  => $sslkeyfile
                       },
                       'ssl_certificate_file-gateway'   => { option => 'ssl_certificate_file',
                                                             value  => $sslkeyfile
                       }
  }

  create_resources('zarafa::option',merge($gateway_options,$options), { file    => $configfile,
                                                                        require => Package[$packages],
                                                                        notify  => Service['zarafa-gateway']
                                                                      })

  service { 'zarafa-gateway':
    ensure  => $ensure,
    enable  => $enable,
    require => Package[$packages]
  }
}
