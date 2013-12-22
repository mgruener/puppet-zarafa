class zarafa::component::monitor (
  $serverhostname = hiera("${module_name}::component::server::hostname",'localhost'),
  $ensure         = hiera("${module_name}::component::monitor::ensure",running),
  $enable         = hiera("${module_name}::component::monitor::enable",true),
  $packages       = hiera("${module_name}::component::monitor::packages",'zarafa-monitor'),
  $sslkeyfile     = hiera("${module_name}::component::monitor::sslkeyfile","/etc/zarafa/ssl/${::fqdn}-monitor.crt"),
  $options        = hiera_hash("${module_name}::component::monitor::options",{}),
  $configfile     = hiera("${module_name}::component::monitor::configfile",'/etc/zarafa/monitor.cfg')
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  if downcase($serverhostname) in downcase([ $::fqdn, $::hostname ]) {
    $zarafaserver = 'localhost'
  }
  else
    $zarafaserver = $serverhostname
  }

  $monitor_options = { 'server_socket-monitor' => { option => 'server_socket',
                                                    value => "https://${zarafaserver}:237/zarafa"
                       },
                       'sslkey_file-monitor'   => { option => 'sslkey_file',
                                                    value  => $sslkeyfile
                       }
  }
 
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
