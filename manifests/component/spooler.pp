class zarafa::component::spooler (
  $sslcertdir     = '/etc/zarafa/ssl',
  $serverhostname = 'localhost',
  $ensure         = running,
  $enable         = true,
  $packages       = 'zarafa-spooler',
  $sslkeyfile     = "${::fqdn}-spooler.crt",
  $options        = {},
  $configfile     = '/etc/zarafa/spooler.cfg'
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

  $spooler_options = { 'server_socket-spooler' => { option => 'server_socket',
                                                    value  => "https://${zarafaserver}:237/zarafa"
                       },
                       'sslkey_file-spooler'   => { option => 'sslkey_file',
                                                    value  => "${sslcertdir}/${sslkeyfile}"
                       }
  }

  create_resources('zarafa::option',merge($spooler_options,$options), { file    => $configfile,
                                                                        require => Package[$packages],
                                                                        notify  => Service['zarafa-spooler']
                                                                      })

  service { 'zarafa-spooler':
    ensure => $ensure,
    enable => $enable,
    require => Package[$packages]
  }
}
