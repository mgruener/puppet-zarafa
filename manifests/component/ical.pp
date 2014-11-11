class zarafa::component::ical (
  $sslcertdir     = '/etc/zarafa/ssl',
  $serverhostname = $::fqdn,
  $ensure         = running,
  $enable         = true,
  $packages       = 'zarafa-ical',
  $sslkeyfile     = "${::fqdn}-ical.crt",
  $options        = {},
  $configfile     = '/etc/zarafa/ical.cfg'
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  $ical_options = { 'server_socket-ical' => { option => 'server_socket',
                                              value => "https://${serverhostname}:237/zarafa"
                    },
                    'ssl_private_key_file-ical'   => { option => 'ssl_private_key_file',
                                                       value  => "${sslcertdir}/${sslkeyfile}"
                    },
                    'ssl_certificate_file-ical'   => { option => 'ssl_certificate_file',
                                                       value  => "${sslcertdir}/${sslkeyfile}"
                    }
  }

  create_resources('zarafa::option',merge($ical_options,$options), { file    => $configfile,
                                                                     require => Package[$packages],
                                                                     notify  => Service['zarafa-ical']
                                                                   })

  service { 'zarafa-ical':
    ensure  => $ensure,
    enable  => $enable,
    require => Package[$packages]
  }
}
