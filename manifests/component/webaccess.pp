class zarafa::component::webaccess (
  $serverhostname = 'localhost',
  $packages =  'zarafa-webaccess',
) {
  package { $packages:
    ensure => present
  }

  if downcase($serverhostname) in downcase([ $::fqdn, $::hostname ]) {
    $zarafaserver = 'localhost'
  }
  else {
    $zarafaserver = $serverhostname
  }

}
