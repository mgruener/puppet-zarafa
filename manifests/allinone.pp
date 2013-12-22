class zarafa::allinone (
  $serverhostname = hiera("${module_name}::component::server::hostname",$::fqdn),
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

  $certdir   = pick($certdata[certdir],'/etc/zarafa/ssl')
  $keydir    = pick($certdata[keydir],'/etc/pki/tls/private')
  $pubkeydir = pick($certdata[pubkeydir],'/etc/zarafa/sslkeys')

  Certtool::Cert {
    certpath        => $certdir,
    keypath         => $keydir,
    pubkeypath      => $pubkeydir,
    organization    => $certdata[organization],
    unit            => $certdata[unit],
    locality        => $certdata[locality],
    state           => $certdata[state],
    country         => $certdata[country],
    caname          => $certdata[caname],
    expiration_days => $certdata[expidation_days]
  }
  
  file { [ $certdir, $keydir, $pubkeydir ]:
    ensure => directory,
  }

  certtool::cert { $certdata[caname]:
    is_ca => true,
    require => [ File[$certdir], File[$keydir] ]
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
    require => [ File[$certdir], File[$keydir], File[$pubkeydir] ]
  }

  certtool::cert { "${serverhostname}-dagent":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$certdir], File[$keydir], File[$pubkeydir] ]
  }
  certtool::cert { "${serverhostname}-ical":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$certdir], File[$keydir], File[$pubkeydir] ]
  }
  certtool::cert { "${serverhostname}-gateway":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$certdir], File[$keydir], File[$pubkeydir] ]
  }
  certtool::cert { "${serverhostname}-search":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$certdir], File[$keydir], File[$pubkeydir] ]
  }
  certtool::cert { "${serverhostname}-monitor":
    usage => $usage,
    unit => "test",
    extract_pubkey => true,
    combine_keycert => true,
    require => [ File[$certdir], File[$keydir], File[$pubkeydir] ]
  }
}
