class zarafa::component::search (
  $sslcertdir     = '/etc/zarafa/ssl',
  $serverhostname = $::fqdn,
  $ensure         = running,
  $enable         = true,
  $packages       = 'zarafa-search',
  $sslkeyfile     = "${::fqdn}-search.crt",
  $options        = {},
  $configfile     = '/etc/zarafa/search.cfg'
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
                                                  value  => "${sslcertdir}/${sslkeyfile}"
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
