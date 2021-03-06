class zarafa::component::monitor (
  $sslcertdir     = '/etc/zarafa/ssl',
  $serverhostname = $::fqdn,
  $ensure         = running,
  $enable         = true,
  $packages       = 'zarafa-monitor',
  $sslkeyfile     = "${::fqdn}-monitor.crt",
  $options        = {},
  $configfile     = '/etc/zarafa/monitor.cfg'
) {

  include zarafa::augeas

  package { $packages:
    ensure => present
  }

  $monitor_options = { 'server_socket-monitor' => { option => 'server_socket',
                                                    value => "https://${serverhostname}:237/zarafa"
                       },
                       'sslkey_file-monitor'   => { option => 'sslkey_file',
                                                    value  => "${sslcertdir}/${sslkeyfile}"
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
