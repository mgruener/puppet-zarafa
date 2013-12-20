class zarafa::search (
  $ensure     = hiera("${module_name}::search::ensure",running),
  $enable     = hiera("${module_name}::search::enable",true),
  $packages   = hiera("${module_name}::search::packages",'zarafa-search'),
  $options    = hiera_hash("${module_name}::search::options",{}),
  $configfile = hiera("${module_name}::search::configfile",'/etc/zarafa/search.cfg')
) {
  package { $packages:
    ensure => present
  }

  service { 'zarafa-search':
    ensure => $ensure,
    enable => $enable
  }

  if $ensure == running {
    $search_enabled = 'yes'
  }
  else {
    $search_enabled = 'no'
  }

  create_resources('zarafa::option',$options, { file => $configfile })

  zarafa::option { 'search_enabled':
    file   => '/etc/zarafa/server.cfg',
    value => $search_enabled
  }
}
