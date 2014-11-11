class zarafa::component::gateway (
  $sslcertdir     = '/etc/zarafa/ssl',
  $serverhostname = $::fqdn,
  $ensure         = running,
  $enable         = true,
  $packages       = 'zarafa-gateway',
  $sslkeyfile     = "${::fqdn}-gateway.crt",
  $options        = {},
  $configfile     = '/etc/zarafa/gateway.cfg'
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  $gateway_options = { 'server_socket-gateway' => { option => 'server_socket',
                                                    value => "https://${serverhostname}:237/zarafa"
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
