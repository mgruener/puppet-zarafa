class zarafa::component::gateway (
  $sslcertdir     = hiera("${module_name}::sslcertdir",'/etc/zarafa/ssl'),
  $serverhostname = hiera("${module_name}::component::server::hostname",'localhost'),
  $ensure         = hiera("${module_name}::component::gateway::ensure",running),
  $enable         = hiera("${module_name}::component::gateway::enable",true),
  $packages       = hiera("${module_name}::component::gateway::packages",'zarafa-gateway'),
  $sslkeyfile     = hiera("${module_name}::component::gateway::sslkeyfile","${::fqdn}-gateway.crt"),
  $options        = hiera_hash("${module_name}::component::gateway::options",{}),
  $configfile     = hiera("${module_name}::component::gateway::configfile",'/etc/zarafa/gateway.cfg')
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  if downcase($serverhostname) in downcase([ $::fqdn, $::hostname ]) {
    $zarafaserver = 'localhost'
  }
  else {
    $zarafaserver = $serverhostname
  }

  $gateway_options = { 'server_socket-gateway' => { option => 'server_socket',
                                                    value => "https://${zarafaserver}:237/zarafa"
                       },
                       'ssl_private_key_file-gateway'   => { option => 'ssl_private_key_file',
                                                             value  => "${sslcertdir}/${sslkeyfile}"
                       },
                       'ssl_certificate_file-gateway'   => { option => 'ssl_certificate_file',
                                                             value  => "${sslcertdir}/${sslkeyfile}"
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
