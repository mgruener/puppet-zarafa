class zarafa::component::ical (
  $sslcertdir     = hiera("${module_name}::sslcertdir",'/etc/zarafa/ssl'),
  $serverhostname = hiera("${module_name}::component::server::hostname",'localhost'),
  $ensure         = hiera("${module_name}::component::ical::ensure",running),
  $enable         = hiera("${module_name}::component::ical::enable",true),
  $packages       = hiera("${module_name}::component::ical::packages",'zarafa-ical'),
  $sslkeyfile     = hiera("${module_name}::component::ical::sslkeyfile","${::fqdn}-ical.crt"),
  $options        = hiera_hash("${module_name}::component::ical::options",{}),
  $configfile     = hiera("${module_name}::component::ical::configfile",'/etc/zarafa/ical.cfg')
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

  $ical_options = { 'server_socket-ical' => { option => 'server_socket',
                                              value => "https://${zarafaserver}:237/zarafa"
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
