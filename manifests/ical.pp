class zarafa::ical (
  $ensure     = hiera("${module_name}::ical::ensure",running),
  $enable     = hiera("${module_name}::ical::enable",true),
  $packages   = hiera("${module_name}::ical::packages",'zarafa-ical'),
  $options    = hiera_hash("${module_name}::ical::options",{}),
  $configfile = hiera("${module_name}::ical::configfile",'/etc/zarafa/ical.cfg')
) {
  package { $packages:
    ensure => present
  }

  create_resources('zarafa::option',$options, { file => $configfile })

  service { 'zarafa-ical':
    ensure => $ensure,
    enable => $enable
  }
}
