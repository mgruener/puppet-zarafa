class zarafa::component::search (
  $ensure         = hiera("${module_name}::component::search::ensure",running),
  $enable         = hiera("${module_name}::component::search::enable",true),
  $packages       = hiera("${module_name}::component::search::packages",'zarafa-search'),
  $serverhostname = hiera("${module_name}::component::search::serverhostname",'localhost'),
  $sslkeyfile     = hiera("${module_name}::component::search::sslkeyfile","/etc/zarafa/ssl/${::fqdn}-search.crt"),
  $options        = hiera_hash("${module_name}::component::search::options",{}),
  $configfile     = hiera("${module_name}::component::search::configfile",'/etc/zarafa/search.cfg')
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  service { 'zarafa-search':
    ensure  => $ensure,
    enable  => $enable,
    require => Package[$packages]
  }

  if $ensure == running {
    $search_enabled = 'yes'
  }
  else {
    $search_enabled = 'no'
  }

  $search_options = { 'server_socket-search' => { option => 'server_socket',
                                                  value => "https://${serverhostname}:237/zarafa"
                      },
                      'sslkey_file-search'   => { option => 'sslkey_file',
                                                  value  => $sslkeyfile
                      }
  }

  create_resources('zarafa::option',merge($search_options,$options), { file    => $configfile,
                                                                       require => Package[$packages],
                                                                       notify  => Service['zarafa-search']
                                                                     })

  zarafa::option { 'search_enabled':
    file   => '/etc/zarafa/server.cfg',
    value => $search_enabled
  }
}
