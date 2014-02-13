class zarafa::allinone (
  $certdata = {},
  $sslcertdir     = '/etc/zarafa/ssl',
  $sslkeydir      = '/etc/pki/tls/private',
  $sslpubkeydir   = '/etc/zarafa/sslkeys',
  $hiera_merge    = false,
) {
  $myclass = "${module_name}::allinone"

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

  case type($hiera_merge) {
    'string': {
      validate_re($hiera_merge, '^(true|false)$', "${myclass}::hiera_merge may be either 'true' or 'false' and is set to <${hiera_merge}>.")
      $hiera_merge_real = str2bool($hiera_merge)
    }
    'boolean': {
      $hiera_merge_real = $hiera_merge
    }
    default: {
      fail("${myclass}::hiera_merge type must be true or false.")
    }
  }

  if !is_hash($certdata) {
      fail("${myclass}::certdata must be a hash.")
  }

  if $hiera_merge_real == true {
    $certdata_real = hiera_hash("${myclass}::certdata",{})
  } else {
    $certdata_real = $certdata
  }

  $serverhostname = pick(getvar("${module_name}::component::server::serverhostname"),$::fqdn)
  $caname = pick($certdata_real[caname],"${serverhostname}_ca")

  Certtool::Cert {
    certpath        => $sslcertdir,
    keypath         => $sslkeydir,
    pubkeypath      => $sslpubkeydir,
    organization    => $certdata_real[organization],
    unit            => $certdata_real[unit],
    locality        => $certdata_real[locality],
    state           => $certdata_real[state],
    country         => $certdata_real[country],
    caname          => $caname,
    expiration_days => $certdata_real[expidation_days]
  }

  file { [ $sslcertdir, $sslkeydir, $sslpubkeydir ]:
    ensure => directory,
  }

  certtool::cert { $caname:
    is_ca   => true,
    require => [ File[$sslcertdir], File[$sslkeydir] ]
  }

  $usage = ['tls_www_server',
            'encryption_key',
            'signing_key',
            'tls_www_client',
            'cert_signing_key',
            'crl_signing_key',
            'code_signing_key',
            'ocsp_signing_key',
            'time_stamping_key',
            'ipsec_ike_key'
  ]

  certtool::cert { $serverhostname:
    usage           => $usage,
    extract_pubkey  => true,
    combine_keycert => true,
    require         => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before          => Class['zarafa::component::server']
  }

  certtool::cert { "${serverhostname}-spooler":
    usage           => $usage,
    extract_pubkey  => true,
    combine_keycert => true,
    require         => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before          => Class['zarafa::component::spooler']
  }
  certtool::cert { "${serverhostname}-dagent":
    usage           => $usage,
    extract_pubkey  => true,
    combine_keycert => true,
    require         => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before          => Class['zarafa::component::dagent']
  }
  certtool::cert { "${serverhostname}-ical":
    usage           => $usage,
    extract_pubkey  => true,
    combine_keycert => true,
    require         => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before          => Class['zarafa::component::ical']
  }
  certtool::cert { "${serverhostname}-gateway":
    usage           => $usage,
    extract_pubkey  => true,
    combine_keycert => true,
    require         => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before          => Class['zarafa::component::gateway']
  }
  certtool::cert { "${serverhostname}-search":
    usage           => $usage,
    extract_pubkey  => true,
    combine_keycert => true,
    require         => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before          => Class['zarafa::component::search']
  }
  certtool::cert { "${serverhostname}-monitor":
    usage           => $usage,
    extract_pubkey  => true,
    combine_keycert => true,
    require         => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before          => Class['zarafa::component::monitor']
  }
  certtool::cert { "${serverhostname}-admin":
    usage           => $usage,
    extract_pubkey  => true,
    combine_keycert => true,
    require         => [ File[$sslcertdir], File[$sslkeydir], File[$sslpubkeydir] ],
    before          => Class['zarafa::component::client']
  }
}
