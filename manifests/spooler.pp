class zarafa::spooler (
  $ensure     = hiera("${module_name}::spooler::ensure",running),
  $enable     = hiera("${module_name}::spooler::enable",true),
  $packages   = hiera("${module_name}::spooler::packages",'zarafa-spooler'),
  $options    = hiera_hash("${module_name}::spooler::options",{}),
  $configfile = hiera("${module_name}::spooler::configfile",'/etc/zarafa/spooler.cfg')
) {
  package { $packages:
    ensure => present
  }

  create_resources('zarafa::option',$options, { file => $configfile })

  service { 'zarafa-spooler':
    ensure => $ensure,
    enable => $enable
  }
}
