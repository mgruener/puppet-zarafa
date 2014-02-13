class zarafa::component::dagent (
  $sslcertdir     = '/etc/zarafa/ssl',
  $serverhostname = 'localhost',
  $ensure         = 'running',
  $enable         = true,
  $packages       = 'zarafa-dagent',
  $sslkeyfile     = "${::fqdn}-dagent.crt",
  $options        = {},
  $configfile     = '/etc/zarafa/dagent.cfg',
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

  $dagent_options = { 'server_socket-dagent' => { option => 'server_socket',
                                                  value => "https://${zarafaserver}:237/zarafa"
                     },
                     'sslkey_file-dagent'    => { option => 'sslkey_file',
                                                  value  => "${sslcertdir}/${sslkeyfile}"
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
