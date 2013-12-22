class zarafa::component::webaccess (
  $serverhostname = hiera("${module_name}::component::server::hostname",'localhost'),
  $packages = hiera("${module_name}::component::webaccess::packages", 'zarafa-webaccess'),
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
