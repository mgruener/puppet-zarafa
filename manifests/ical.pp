class zarafa::ical (
  $ensure         = hiera("${module_name}::ical::ensure",running),
  $enable         = hiera("${module_name}::ical::enable",true),
  $packages       = hiera("${module_name}::ical::packages",'zarafa-ical'),
  $serverhostname = hiera("${module_name}::ical::serverhostname",'localhost'),
  $options        = hiera_hash("${module_name}::ical::options",{}),
  $configfile     = hiera("${module_name}::ical::configfile",'/etc/zarafa/ical.cfg')
) {
  package { $packages:
    ensure => present
  }

  $ical_options = { 'server_socket-ical' => { option => 'server_socket',
                                              value => "http://${serverhostname}:236/zarafa" }}

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
