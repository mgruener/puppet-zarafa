class zarafa::allinone (
  $serverhostname = hiera("${module_name}::component::server::hostname",$::fqdn),
  $sslcertdir     = hiera("${module_name}::sslcertdir",'/etc/zarafa/ssl'),
  $sslkeydir      = hiera("${module_name}::sslkeydir",'/etc/pki/tls/private'),
  $sslpubkeydir   = hiera("${module_name}::sslpubkeydir",'/etc/zarafa/sslkeys'),
  $certdata       = hiera_hash("${module_name}::allinone::certdata"),
) {
  include zarafa::dbhost
  include zarafa::component::client
  include zarafa::component::server
  include zarafa::component::dagent
  include zarafa::component::spooler
  include zarafa::component::gateway
  include zarafa::component::ical
  include zarafa::component::monitor
  include zarafa::component::search
  include zarafa::component::webaccess

  Class['zarafa::dbhost'] -> Class['zarafa::component::server'] 
  Class['zarafa::component::server'] -> Class['zarafa::component::dagent']
  Class['zarafa::component::server'] -> Class['zarafa::component::spooler']
  Class['zarafa::component::server'] -> Class['zarafa::component::gateway']
  Class['zarafa::component::server'] -> Class['zarafa::component::ical']
  Class['zarafa::component::server'] -> Class['zarafa::component::monitor']
  Class['zarafa::component::server'] -> Class['zarafa::component::search']

  Certtool::Cert {
    certpath        => $sslcertdir,
    keypath         => $sslkeydir,
    pubkeypath      => $sslpubkeydir,
    organization    => $certdata[organization],
    unit            => $certdata[unit],
    locality        => $certdata[locality],
    state           => $certdata[state],
    country         => $certdata[country],
    caname          => $certdata[caname],
    expiration_days => $certdata[expidation_days]
  }
  
  file { [ $sslcertdir, $sslkeydir, $sslpubkeydir ]:
    ensure => directory,
  }

  certtool::cert { $certdata[caname]:
    is_ca => true,
    require => [ File[$sslcertdir], File[$sslkeydir] ]
  }

  $usage = [ "tls_www_server",
             "encryption_key",
             "signing_key",
             "tls_www_client",
             "cert_signing_key",
             "crl_signing_key",
             "code_signing_key",
             "ocsp_signing_key",
             "time_stamping_key",
             "ipsec_ike_key"
  ] 

  certtool::cert { $serverhostname:
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before => Class['zarafa::component::server']
  }

  certtool::cert { "${serverhostname}-spooler":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before => Class['zarafa::component::spooler']
  }
  certtool::cert { "${serverhostname}-dagent":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before => Class['zarafa::component::dagent']
  }
  certtool::cert { "${serverhostname}-ical":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before => Class['zarafa::component::ical']
  }
  certtool::cert { "${serverhostname}-gateway":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before => Class['zarafa::component::gateway']
  }
  certtool::cert { "${serverhostname}-search":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before => Class['zarafa::component::search']
  }
  certtool::cert { "${serverhostname}-monitor":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before => Class['zarafa::component::monitor']
  }
  certtool::cert { "${serverhostname}-admin":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before => Class['zarafa::component::client']
  }
}
