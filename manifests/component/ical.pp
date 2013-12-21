class zarafa::component::ical (
  $ensure         = hiera("${module_name}::component::ical::ensure",running),
  $enable         = hiera("${module_name}::component::ical::enable",true),
  $packages       = hiera("${module_name}::component::ical::packages",'zarafa-ical'),
  $serverhostname = hiera("${module_name}::component::ical::serverhostname",'localhost'),
  $sslkeyfile     = hiera("${module_name}::component::ical::sslkeyfile","/etc/zarafa/ssl/${::fqdn}-ical.crt"),
  $options        = hiera_hash("${module_name}::component::ical::options",{}),
  $configfile     = hiera("${module_name}::component::ical::configfile",'/etc/zarafa/ical.cfg')
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  $ical_options = { 'server_socket-ical' => { option => 'server_socket',
                                              value => "https://${serverhostname}:237/zarafa"
                    },
                    'ssl_private_key_file-ical'   => { option => 'ssl_private_key_file',
                                                       value  => $sslkeyfile
                    },
                    'ssl_certificate_file-ical'   => { option => 'ssl_certificate_file',
                                                       value  => $sslkeyfile
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
