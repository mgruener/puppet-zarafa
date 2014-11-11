class zarafa::component::webaccess (
  $serverhostname = $::fqdn,
  $packages =  'zarafa-webaccess',
) {
  package { $packages:
    ensure => present
  }

}
