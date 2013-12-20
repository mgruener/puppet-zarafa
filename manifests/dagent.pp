class zarafa::dagent (
  $ensure     = hiera("${module_name}::dagent::ensure",running),
  $enable     = hiera("${module_name}::dagent::enable",true),
  $packages   = hiera("${module_name}::dagent::packages",'zarafa-dagent'),
  $options    = hiera_hash("${module_name}::dagent::options",{}),
  $configfile = hiera("${module_name}::dagent::configfile",'/etc/zarafa/dagent.cfg')
) {
  package { $packages:
    ensure => present
  }

  create_resources('zarafa::option',$options, { file => $configfile })

  service { 'zarafa-dagent':
    ensure => $ensure,
    enable => $enable
  }
}