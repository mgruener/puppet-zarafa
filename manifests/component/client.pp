class zarafa::component::client (
  $sslcertdir     = '/etc/zarafa/ssl',
  $serverhostname = $::fqdn,
  $packages       = ['zarafa-client', 'zarafa-utils'],
  $sslkeyfile     = "${::fqdn}-admin.crt",
  $options        = {},
  $configfile     = '/etc/zarafa/admin.cfg',
) {
  package { $packages:
    ensure => present
  }

  $client_options = { 'server_socket-client' => { option => 'server_socket',
                                                  value => "https://${serverhostname}:237/zarafa"
                      },
                      'sslkey_file-client'    => { option => 'sslkey_file',
                                                   value  => "${sslcertdir}/${sslkeyfile}"
                      }
  }

  create_resources('zarafa::option',merge($client_options,$options), { file    => $configfile, 
                                                                       require => Package[$packages],
                                                                       notify  => Service['zarafa-dagent']
                                                                     })
}
