class zarafa::gateway (
  $ensure         = hiera("${module_name}::gateway::ensure",running),
  $enable         = hiera("${module_name}::gateway::enable",true),
  $serverhostname = hiera("${module_name}::gateway::serverhostname",'localhost'),
  $packages       = hiera("${module_name}::gateway::packages",'zarafa-gateway'),
  $options        = hiera_hash("${module_name}::gateway::options",{}),
  $configfile     = hiera("${module_name}::gateway::configfile",'/etc/zarafa/gateway.cfg')
) {
  package { $packages:
    ensure => present
  }

  create_resources('zarafa::option',$options, { file => $configfile, require => Package[$packages] })

  service { 'zarafa-gateway':
    ensure  => $ensure,
    enable  => $enable,
    require => Package[$packages]
  }
}
