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

  $monitor_options = { 'server_socket-monitor' => { option => 'server_socket',
                                                    value => "http://${serverhostname}:236/zarafa" }}
 
  create_resources('zarafa::option',merge($monitor_options,$options), { file    => $configfile,
                                                                        require => Package[$packages],
                                                                        notify  => Service['zarafa-monitor']
                                                                      })

  service { 'zarafa-monitor':
    ensure  => $ensure,
    enable  => $enable,
    require => Package[$packages]
  }
}
