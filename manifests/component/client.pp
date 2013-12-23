class zarafa::component::client (
  $sslcertdir     = hiera("${module_name}::sslcertdir",'/etc/zarafa/ssl'),
  $serverhostname = hiera("${module_name}::component::server::hostname",'localhost'),
  $packages = hiera("${module_name}::component::client::packages",['zarafa-client', 'zarafa-utils']),
  $sslkeyfile     = hiera("${module_name}::component::client::sslkeyfile","${::fqdn}-admin.crt"),
  $options        = hiera_hash("${module_name}::component::client::options",{}),
  $configfile     = hiera("${module_name}::component::client::configfile",'/etc/zarafa/admin.cfg')
) {
  package { $packages:
    ensure => present
  }

  if downcase($serverhostname) in downcase([ $::fqdn, $::hostname ]) {
    $zarafaserver = 'localhost'
  }
  else {
    $zarafaserver = $serverhostname
  }

  $client_options = { 'server_socket-client' => { option => 'server_socket',
                                                  value => "https://${zarafaserver}:237/zarafa"
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
