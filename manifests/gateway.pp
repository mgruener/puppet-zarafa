class zarafa::gateway (
  $ensure         = hiera("${module_name}::gateway::ensure",running),
  $enable         = hiera("${module_name}::gateway::enable",true),
  $serverhostname = hiera("${module_name}::gateway::serverhostname",'localhost'),
  $packages       = hiera("${module_name}::gateway::packages",'zarafa-gateway'),
  $options        = hiera_hash("${module_name}::gateway::options",{}),
  $configfile     = hiera("${module_name}::gateway::configfile",'/etc/zarafa/gateway.cfg')
) {
  package { $packages:
    ensure => present
  }

  $gateway_options = { 'server_socket-gateway' => { option => 'server_socket',
                                                    value => "http://${serverhostname}:236/zarafa" }}

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
