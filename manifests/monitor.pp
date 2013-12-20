class zarafa::monitor (
  $ensure         = hiera("${module_name}::monitor::ensure",running),
  $enable         = hiera("${module_name}::monitor::enable",true),
  $packages       = hiera("${module_name}::monitor::packages",'zarafa-monitor'),
  $serverhostname = hiera("${module_name}::monitor::serverhostname",'localhost'),
  $options        = hiera_hash("${module_name}::monitor::options",{}),
  $configfile     = hiera("${module_name}::monitor::configfile",'/etc/zarafa/monitor.cfg')
) {
  package { $packages:
    ensure => present
  }

  create_resources('zarafa::option',$options, { file => $configfile, require => Package[$packages] })

  service { 'zarafa-monitor':
    ensure  => $ensure,
    enable  => $enable,
    require => Package[$packages]
  }
}
